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

public class Mob1 : Character
{
    public override void OnAwake()
    {
        base.OnAwake();
        HealthMax = new CharacterStat(10f);
        Speed = new CharacterStat(3f);
        

        Renderer = transform.GetChild(0).GetComponent<SkeletonMecanim>();
    }
}
