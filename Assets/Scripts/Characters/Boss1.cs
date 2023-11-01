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

    private Slider SilderHealth;

    public override void OnAwake()
    {
        base.OnAwake();
        SilderHealth = GameObject.Find("BossHealthBar").GetComponent<Slider>();
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


        SilderHealth.value = base.Health / HealthMax.Final;
    }

    public override void Dead()
    {
        SilderHealth.value = base.Health / HealthMax.Final;
        base.Dead();
        AerutaDebug.i.ShowStatistics();
    }
}
