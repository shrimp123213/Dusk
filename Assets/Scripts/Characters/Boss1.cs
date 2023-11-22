using System.Collections;
using System.Collections.Generic;
using System.ComponentModel;
using TMPro;
using UnityEngine;
using UnityEngine.InputSystem;
using UnityEngine.SceneManagement;
using UnityEngine.UI;

public class Boss1 : Character
{

    private Slider SliderHealthTop;
    private Slider SliderHealthBottom;

    private float topMoveSpeed;
    private float bottomMoveSpeed;

    private float lastHealth;

    private float waitSliderHealthMove;

    public override void OnAwake()
    {
        HealthMax = new CharacterStat(500f);
        base.OnAwake();
        SliderHealthTop = GameObject.Find("BossHealthTop").GetComponent<Slider>();
        SliderHealthBottom = GameObject.Find("BossHealthBottom").GetComponent<Slider>();

        topMoveSpeed = .05f;
        bottomMoveSpeed = .05f;
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
        base.Dead();
        AerutaDebug.i.ShowStatistics();
    }
}
