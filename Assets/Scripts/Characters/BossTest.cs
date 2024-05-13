using System.Collections;
using System.Collections.Generic;
using System.ComponentModel;
using TMPro;
using UnityEngine;
using UnityEngine.InputSystem;
using UnityEngine.SceneManagement;
using UnityEngine.UI;
using Spine.Unity;
using DG.Tweening;

public class BossTest : Character
{
    private Slider SliderHealthTop;
    private Slider SliderHealthBottom;

    private float topMoveSpeed;
    private float bottomMoveSpeed;

    private float lastHealth;

    private float waitSliderHealthMove;

    private bool startedFade;
    
    private GameObject door;
    private Color doorSpriteColor;
    
    public Transform BossHealthBar;
    public TMP_Text BossName;
    public GameObject drama;
    private bool dramaEnd = false;
    private bool doorActive = false;
    
    public override void OnAwake()
    {
        HealthMax = new CharacterStat(400f);
        Speed = new CharacterStat(3f);
        base.OnAwake();
        SliderHealthTop = GameObject.Find("BossHealthTop").GetComponent<Slider>();
        SliderHealthBottom = GameObject.Find("BossHealthBottom").GetComponent<Slider>();

        door = GameObject.Find("Door");
        doorSpriteColor = door.GetComponent<SpriteRenderer>().color;
        
        topMoveSpeed = .05f;
        bottomMoveSpeed = .05f;
        Renderer = transform.GetChild(0).GetComponent<SkeletonMecanim>();
    }

    public override void OnUpdate()
    {
        base.OnUpdate();


        if (lastHealth != base.Health)
            HealthChenged();

        if (waitSliderHealthMove <= 0f)
        {
            SliderHealthTop.value = Mathf.MoveTowards(SliderHealthTop.value, base.Health / HealthMax.Final,
                topMoveSpeed * Time.deltaTime);
            SliderHealthBottom.value = Mathf.MoveTowards(SliderHealthBottom.value, base.Health / HealthMax.Final,
                bottomMoveSpeed * Time.deltaTime);
        }
        else
            waitSliderHealthMove -= Time.deltaTime;

        if (isDead)
        {
            
            if (!startedFade && Ani.GetCurrentAnimatorClipInfo(0).Length > 0 && Ani.GetCurrentAnimatorClipInfo(0)[0].clip.name == "boss1_dead" && Ani.GetCurrentAnimatorStateInfo(0).normalizedTime > .8f)
            {
                startedFade = true;
                //BossHealthBar.localScale = new Vector3(Mathf.MoveTowards(BossHealthBar.localScale.x, 0f, 1 * Time.deltaTime), .75f, .75f);

                DOVirtual.Color(Renderer.skeleton.GetColor(), new Color(1, 1, 1, 0), 3f, (value) =>
                {
                    Renderer.skeleton.SetColor(value);
                }).OnComplete(() =>
                {
                    BossHealthBar.localScale = new Vector3(0f, .75f, .75f);
                    BossName.text = "";
                    if (dramaEnd == false)
                    {
                        dramaEnd = true;
                        drama.SetActive(true);
                    }
                    
                    DOVirtual.Color(doorSpriteColor, new Color(1, 1, 1, 0), 1f, (value) =>
                    {
                        doorSpriteColor = door.GetComponent<SpriteRenderer>().color = value;
                    });
                    
                });

            }
            if (doorSpriteColor.a <= 0 && !doorActive)
            {
                door.SetActive(false);
                MusicManager.i.Play("OutSide", 1f, 1f);
                doorActive = true;
            }
            
        }
    }

    public override void Dead()
    {
        isDead = true;
        /*DOVirtual.Color(Renderer.skeleton.GetColor(), new Color(1, 1, 1, 0), 1f, (value) =>
        {
            Renderer.skeleton.SetColor(value);
            Destroy(gameObject, 1f);
        });*/
        
        SliderHealthTop.value = base.Health / HealthMax.Final;
        
        AITree.enabled = false;
        base.gameObject.layer = 13;
        /*for (int i = 0; i < UnityEngine.Random.Range(2, 4); i++)
        {
            //UnityEngine.Object.Instantiate(GeneralPrefabSO.i.P_HealthShard, base.transform.position + new Vector3(0f, 1.25f), Quaternion.identity);
        }*/
        //base.gameObject.SetActive(value: false);
        StartAction(DeadAction);
        HurtBox.enabled = false;
        CollisionBlockMove.enabled = false;
        
    }
    
    public void HealthChenged()
    {
        if ((float)SliderHealthTop.value > (float)(base.Health / HealthMax.Final))
            SliderHealthTop.value = base.Health / HealthMax.Final;

        if ((float)SliderHealthBottom.value < (float)(base.Health / HealthMax.Final))
            SliderHealthBottom.value = base.Health / HealthMax.Final;

        lastHealth = base.Health;

        waitSliderHealthMove = .5f;
    }
    
    public override void SetAnimationIdle()
    {

    }
}
