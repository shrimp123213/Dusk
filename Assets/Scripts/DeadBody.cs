using System;
using System.Collections;
using System.Collections.Generic;
using Spine.Unity;
using UnityEngine;
using DG.Tweening;
using UnityEngine.UI;

public class DeadBody : MonoBehaviour
{
    public Transform deadBody;
    public PlayerMain playerMain;
    public SkeletonMecanim deadBodyRender;
    
    public Image reviveSlider;
    
    public float reviveTime = 3f;
    private float reviveTimer = 0f;
    
    private Animator deadBodyAnimator;

    private void Awake()
    {
        playerMain = PlayerMain.i;
        deadBody = gameObject.transform.GetChild(0);
        deadBodyRender = deadBody.GetComponent<SkeletonMecanim>();
        deadBodyAnimator = deadBody.GetComponent<Animator>();
    }
    
    void Start()
    {
        reviveSlider.fillAmount = 0;
    }
    
    void Update()
    {
        reviveSlider.fillAmount = reviveTimer / reviveTime;
    }
    
    public void SetFace(Character _m)
    {
        deadBody.localScale = new Vector3(_m.Facing, 1, 1);
        DOVirtual.Color(deadBodyRender.skeleton.GetColor(), new Color(.3f, .3f, .3f, 1), 1f, (value) =>
        {
            deadBodyRender.skeleton.SetColor(value);
        });
        deadBodyAnimator.Play("Failed", 0, 1);
    }

    private void OnTriggerStay2D(Collider2D other)
    {
        if (other.CompareTag("Player"))
        {
            reviveTimer += Time.deltaTime;
            reviveTimer = Mathf.Clamp(reviveTimer, 0, reviveTime);
        }
        if (reviveTimer >= reviveTime)
        {
            //playerMain.Revive();
            Destroy(gameObject);
            reviveTimer = 0;
        }
    }
    
    private void OnTriggerExit2D(Collider2D other)
    {
        reviveTimer -= Time.deltaTime;
        reviveTimer = Mathf.Clamp(reviveTimer, 0, reviveTime);
    }
}
