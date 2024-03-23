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

public class BossTest : Mob1
{
    public override void OnAwake()
    {
        base.OnAwake();
        HealthMax = new CharacterStat(200f);
        Speed = new CharacterStat(3f);
        
        Renderer = transform.GetChild(0).GetComponent<SkeletonMecanim>();
    }
    
}
