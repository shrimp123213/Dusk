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

public class Boss1 : Character
{

    private Slider SliderHealthTop;
    private Slider SliderHealthBottom;

    private float topMoveSpeed;
    private float bottomMoveSpeed;

    private float lastHealth;

    private float waitSliderHealthMove;

    private bool startedFade;

    public override void OnAwake()
    {
        HealthMax = new CharacterStat(300f);
        Speed = new CharacterStat(3f);
        base.OnAwake();
        SliderHealthTop = GameObject.Find("BossHealthTop").GetComponent<Slider>();
        SliderHealthBottom = GameObject.Find("BossHealthBottom").GetComponent<Slider>();

        topMoveSpeed = .05f;
        bottomMoveSpeed = .05f;

        Renderer = transform.GetChild(0).GetComponent<SkeletonMecanim>();
    }

    public override void AttackLand()
    {
        base.AttackLand();


    }

    public override void StartAction(ActionBaseObj _actionBaseObj)
    {
        base.StartAction(_actionBaseObj);


    }

    public override void OnUpdate()
    {
        base.OnUpdate();


        if (lastHealth != base.Health)
            HealthChenged();

        if (waitSliderHealthMove <= 0f)
        {
            SliderHealthTop.value = Mathf.MoveTowards(SliderHealthTop.value, base.Health / HealthMax.Final, topMoveSpeed * Time.deltaTime);
            SliderHealthBottom.value = Mathf.MoveTowards(SliderHealthBottom.value, base.Health / HealthMax.Final, bottomMoveSpeed * Time.deltaTime);
        }
        else
            waitSliderHealthMove -= Time.deltaTime;


        if (isDead)
        {
            if (!startedFade && Ani.GetCurrentAnimatorClipInfo(0).Length > 0 && Ani.GetCurrentAnimatorClipInfo(0)[0].clip.name == "boss1-1_DF_death" && Ani.GetCurrentAnimatorStateInfo(0).normalizedTime > .8f)
            {
                startedFade = true;

                DOVirtual.Color(Renderer.skeleton.GetColor(), new Color(1, 1, 1, 0), 3f, (value) =>
                {
                    Renderer.skeleton.SetColor(value);
                });
            }
            if (Renderer.skeleton.GetColor().a <= 0 && !AerutaDebug.i.Statistics.activeSelf)
            {
                AerutaDebug.i.ShowStatistics();
            }
        }
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

    public override void Dead()
    {
        SliderHealthTop.value = base.Health / HealthMax.Final;

        isDead = true;
        base.gameObject.layer = 13;
        AITree.enabled = false;
        StartAction(DeadAction);
        HurtBox.enabled = false;
        CollisionBlockMove.enabled = false;
    }

    public override void SetAnimationIdle()
    {

    }
}
