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
    public override void OnAwake()
    {
        HealthMax = new CharacterStat(300f);
        Speed = new CharacterStat(3f);
        base.OnAwake();
        Renderer = transform.GetChild(0).GetComponent<SkeletonMecanim>();
    }
    
    public override void Dead()
    {
        isDead = true;
        DOVirtual.Color(Renderer.skeleton.GetColor(), new Color(1, 1, 1, 0), 1f, (value) =>
        {
            Renderer.skeleton.SetColor(value);
            Destroy(gameObject, 1f);
        });
        AITree.enabled = false;
        base.gameObject.layer = 13;
        for (int i = 0; i < UnityEngine.Random.Range(2, 4); i++)
        {
            //UnityEngine.Object.Instantiate(GeneralPrefabSO.i.P_HealthShard, base.transform.position + new Vector3(0f, 1.25f), Quaternion.identity);
        }
        //base.gameObject.SetActive(value: false);
        //StartAction(DeadAction);
        HurtBox.enabled = false;
        CollisionBlockMove.enabled = false;
    }
}
