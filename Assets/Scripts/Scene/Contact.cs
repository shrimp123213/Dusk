using System;
using System.Collections;
using System.Collections.Generic;
using BehaviorDesigner.Runtime;
using UnityEngine;
using TMPro;
using UnityEngine.UI;
using DG.Tweening;
using Spine.Unity;

public class Contact : MonoBehaviour
{
    public Animator[] fences;

    public BehaviorTree AITree;
    private Animator ani;

    public Transform BossHealthBar;
    public TMP_Text BossName;
    public Image BossNameBackground;

    private float speed;
    private float waitTime;
    private float waitTimeMax = .5f;

    public Vector2 endPos;
    public Vector2 endSize;
    private int startFontSize;
    public int endFontSize;
    private float progress;
    private bool startedMove;

    private bool triggered;
    private bool aniStoped;

    private float afterFencesUpWaitTime;

    void Start()
    {
        ani = AITree.GetComponentInChildren<Animator>();
        ani.Play("boss1-1_ST_sit_idle");

        waitTime = 0;
    }

    private void Update()
    {
        if (ani.GetCurrentAnimatorClipInfo(0).Length > 0 && ani.GetCurrentAnimatorClipInfo(0)[0].clip.name == "boss1-1_ST_start") 
        {
            if (ani.GetCurrentAnimatorStateInfo(0).normalizedTime > 285f / 501f && ani.GetCurrentAnimatorStateInfo(0).normalizedTime < 318f / 501f) 
            {
                fences[0].Play("FenceUp");
                fences[1].Play("FenceUp");
            }
            if (ani.GetCurrentAnimatorStateInfo(0).normalizedTime > 318f / 501f && ani.GetCurrentAnimatorStateInfo(0).normalizedTime < 435f / 501f)
            {
                afterFencesUpWaitTime += Time.deltaTime;
                if (afterFencesUpWaitTime > .5f)
                    ani.speed = 1;
                else
                    ani.speed = 0;
            }
            else if (ani.GetCurrentAnimatorStateInfo(0).normalizedTime > 435f / 501f && ani.GetCurrentAnimatorStateInfo(0).normalizedTime < 450f / 501f)
            {
                speed = 1f;
            }
            else if (ani.GetCurrentAnimatorStateInfo(0).normalizedTime > 450f / 501f && ani.GetCurrentAnimatorStateInfo(0).normalizedTime < 495f / 501f && !aniStoped)
            {
                aniStoped = true;
                ani.speed = 0;
            }
            else if (ani.GetCurrentAnimatorStateInfo(0).normalizedTime > 495f / 501f)
            {
                ani.speed = 0;
            }
        }
        if (ani.GetCurrentAnimatorClipInfo(0).Length > 0 && ani.GetCurrentAnimatorClipInfo(0)[0].clip.name != "boss1-1_ST_start" && ani.GetCurrentAnimatorClipInfo(0)[0].clip.name != "boss1-1_ST_sit_idle") 
        {
            //AITree.GetComponent<Character>().HitEffect.HitStun = .01f;

            Camcam.i.Boss = TransformUtility.FindTransform(AITree.transform, "Head");
            Camcam.i.BossShow = false;

            PlayerMain.i.CanInput = true;

            AITree.GetComponentInChildren<SkeletonMecanim>().UpdateTiming = UpdateTiming.InFixedUpdate;
        }

        if (speed > 0f)
        {
            if (waitTime > 0f)
                waitTime -= Time.deltaTime;
            else
            {
                if (BossNameBackground.rectTransform.rect.size.x <= 3000)
                {
                    BossNameBackground.color = BossNameBackground.color + new Color(0f, 0f, 0f, 2f * Time.deltaTime);
                    BossNameBackground.rectTransform.SetSizeWithCurrentAnchors(RectTransform.Axis.Horizontal, BossNameBackground.rectTransform.rect.size.x + 9000f * Time.deltaTime);
                    BossNameBackground.rectTransform.SetSizeWithCurrentAnchors(RectTransform.Axis.Vertical, BossNameBackground.rectTransform.rect.size.y + 9000f * Time.deltaTime);
                }
                else
                {
                    if (BossName.text == "")
                    {
                        waitTime = waitTimeMax * 2;
                        BossName.text = "±ó¸t¥D±Ð-¥¾¬¥";
                    }
                }
            }

            if (BossName.text == "±ó¸t¥D±Ð-¥¾¬¥" && waitTime <= 0f) 
            {
                if (!startedMove)
                {
                    startedMove = true;
                    BossName.rectTransform.DOLocalMove(endPos, speed - .1f);
                    BossName.rectTransform.DOSizeDelta(endSize, speed - .1f);

                    startFontSize = (int)BossName.fontSize;
                    progress = 0;
                    ani.speed = 1;
                }
                else
                {
                    progress += speed * 1.25f * Time.deltaTime; 
                    BossName.fontSize = Mathf.Lerp(startFontSize, endFontSize, progress);
                    BossNameBackground.color = BossNameBackground.color - new Color(0f, 0f, 0f, .25f * progress);
                }

                if (BossName.rectTransform.localPosition == (Vector3)endPos)
                {
                    ani.speed = 1;
                    BossHealthBar.localScale = new Vector3(Mathf.MoveTowards(BossHealthBar.localScale.x, .75f, speed * Time.deltaTime), .75f, .75f);
                }

                if (BossHealthBar.localScale.x == .75f)
                    gameObject.SetActive(false);
            }
        }
    }

    public void Skip()
    {
        AITree.enabled = true;
        //ani.Play("boss1-1_ST_start");
        AerutaDebug.i.StartGameTime = Time.unscaledTime;

        Camcam.i.BossShow = false;

        PlayerMain.i.StopMove();
        PlayerMain.i.CanInput = true;

        triggered = true;


        fences[0].Play("FenceUp");
        fences[1].Play("FenceUp");

        BossName.text = "±ó¸t¥D±Ð-¥¾¬¥";

        BossName.rectTransform.DOLocalMove(endPos, 0f);
        BossName.rectTransform.DOSizeDelta(endSize, 0f);

        BossName.fontSize = endFontSize;
        BossNameBackground.color = new Color(0f, 0f, 0f, 0f);

        BossHealthBar.localScale = new Vector3(.75f, .75f, .75f);

        MusicManager.i.Play("Zealot", 46f, 5f);

        AITree.GetComponentInChildren<SkeletonMecanim>().UpdateTiming = UpdateTiming.InFixedUpdate;

        gameObject.SetActive(false);
    }

    private void OnTriggerEnter2D(Collider2D other)
    {
        if (other.CompareTag("Player") && !triggered)
        {
            //Skip();

            AITree.enabled = true;
            ani.Play("boss1-1_ST_start");
            AerutaDebug.i.StartGameTime = Time.unscaledTime;

            Camcam.i.BossShow = true;

            PlayerMain.i.StopMove();
            PlayerMain.i.CanInput = false;
            
            Camcam.i.Boss = TransformUtility.FindTransform(AITree.transform, "Head");
            
            triggered = true;

            MusicManager.i.Play("Zealot", 46f, 5f);
        }
    }
}
