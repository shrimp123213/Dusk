using System.Collections;
using System.Collections.Generic;
using Unity.VisualScripting;
using UnityEngine;
using UnityEngine.UI;

public class Butterfly : MonoBehaviour
{
    public GameObject BlastEffect;
    public GameObject AppearEffect;
    [SerializeField]
    private GameObject TraceEffect;

    public Character MarkTarget;

    public bool isAppear;
    private bool onTarget;

    private float moveDelay;
    private float moveDelayMax = .3f;

    private Animator Ani;

    public static Butterfly i;

    private Slider SliderMarkTime;

    [SerializeField]
    private float speedMin;
    private float speed;
    [SerializeField]
    private float tolerance;

    private float targetDistance;


    public CharacterStat MarkTimeMax = new CharacterStat(10f);

    public CharacterStat CooldownMax = new CharacterStat(30f);

    [SerializeField]
    private float _MarkTime;
    public float MarkTime
    {
        get
        {
            return _MarkTime;
        }
        set
        {
            _MarkTime = Mathf.Clamp(value, 0f, MarkTimeMax.Final);
        }
    }

    [SerializeField]
    private float _Cooldown;
    public float Cooldown
    {
        get
        {
            return _Cooldown;
        }
        set
        {
            _Cooldown = Mathf.Clamp(value, 0f, CooldownMax.Final);
        }
    }

    private void Awake()
    {
        i = this;
        Ani = GetComponentInChildren<Animator>();
        SliderMarkTime = GetComponentInChildren<Slider>();
        speed = speedMin;
        SliderMarkTime.gameObject.SetActive(false);
    }

    private void Update()
    {
        Cooldown = Mathf.Clamp(Cooldown - Time.deltaTime, 0f, CooldownMax.Final);

        moveDelay= Mathf.Clamp(moveDelay + Time.deltaTime, 0f, moveDelayMax);

        CalculatMarkTime();

        if ((bool)MarkTarget && onTarget && MarkTime <= 0f && isAppear)
        {
            Disappear();
        }

        if (Cooldown <= 0f && !isAppear)
        {
            Appear();
        }

        if ((bool)MarkTarget && !onTarget && moveDelay >= moveDelayMax) 
        {
            MoveToTarget();
        }
    }

    private void CalculatMarkTime()
    {
        MarkTime = Mathf.Clamp(MarkTime - Time.deltaTime, 0f, MarkTimeMax.Final);

        //if(onTarget)
        //玩家打擊敵人後增加MarkTime

        SliderMarkTime.value = MarkTime / MarkTimeMax.Final;
    }

    private void MoveToTarget()
    {
        transform.position = Vector2.MoveTowards(transform.position, MarkTarget.transform.position + (Vector3)MarkTarget.MarkPos, speed * Time.deltaTime);
        speed += Time.deltaTime * 10;

        targetDistance = Vector3.Distance(transform.position, MarkTarget.transform.position + (Vector3)MarkTarget.MarkPos);

        if (targetDistance < tolerance)
        {
            transform.position = MarkTarget.transform.position + (Vector3)MarkTarget.MarkPos;

            speed = speedMin;
            onTarget = true;
            MarkTime = MarkTimeMax.Final;

            SliderMarkTime.gameObject.SetActive(true);

            transform.parent = MarkTarget.transform;
        }
    }

    public void Appear()
    {
        Ani.Play("Appear");
        Ani.Update(0f);

        moveDelay = 0f;

        Object.Instantiate(AppearEffect, transform.position, Quaternion.identity, transform);

        transform.position = PlayerMain.i.transform.position + (Vector3)PlayerMain.i.MarkPos;
        transform.parent = PlayerMain.i.transform;

        isAppear = true;

        TraceEffect.SetActive(true);
    }

    public void Disappear()
    {
        Ani.Play("Disappear");
        Ani.Update(0f);

        SliderMarkTime.gameObject.SetActive(false);

        MarkTarget = null;
        onTarget = false;

        isAppear = false;

        TraceEffect.SetActive(false);
    }

    public void Blast()
    {
        Disappear();

        Object.Instantiate(BlastEffect, transform.position, Quaternion.identity, transform);
    }
}
