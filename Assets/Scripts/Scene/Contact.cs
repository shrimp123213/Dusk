using System;
using System.Collections;
using System.Collections.Generic;
using BehaviorDesigner.Runtime;
using UnityEngine;
using TMPro;

public class Contact : MonoBehaviour
{
    public Animator[] fences;

    public BehaviorTree AITree;
    private Animator ani;

    public Transform BossHealthBar;
    public TMP_Text BossName;
    
    private float speed;

    void Start()
    {
        ani = AITree.GetComponentInChildren<Animator>();
        ani.Play("boss1-1_ST_sit_idle");
    }

    private void Update()
    {
        if (ani.GetCurrentAnimatorClipInfo(0).Length > 0 && ani.GetCurrentAnimatorClipInfo(0)[0].clip.name == "boss1-1_ST_start") 
        {
            if (ani.GetCurrentAnimatorStateInfo(0).normalizedTime > 285f / 501f) 
            {
                fences[0].Play("FenceUp");
                fences[1].Play("FenceUp");

                speed = 1f;

            }
            if (ani.GetCurrentAnimatorStateInfo(0).normalizedTime > 330f / 501f)
            {
                //AITree.GetComponent<Character>().HitEffect.HitStun = .01f;

                Camcam.i.UseOverride = false;

                PlayerMain.i.CanInput = true;
            }
;
        }
        
        if (speed > 0f)
        {
            BossHealthBar.localScale = new Vector3(Mathf.MoveTowards(BossHealthBar.localScale.x, .75f, speed * Time.deltaTime), .75f, .75f);

            if (BossHealthBar.localScale == Vector3.one * .75f)
            {
                BossName.color = new Color(1f, 1f, 1f, Mathf.MoveTowards(BossName.color.a, 1f, speed * Time.deltaTime));

                if (BossName.color.a == 1f)
                    gameObject.SetActive(false);
            }
        }
    }

    private void OnTriggerEnter2D(Collider2D other)
    {
        if (other.CompareTag("Player"))
        {
            AITree.enabled = true;
            //ani.Play("boss1-1_ST_start");
            AerutaDebug.i.StartGameTime = Time.unscaledTime;

            Camcam.i.UseOverride = true;
            Camcam.i.PosOverride = new Vector3(AITree.transform.position.x, -3f, -10f);

            PlayerMain.i.StopMove();
            PlayerMain.i.CanInput = false;
            
            Camcam.i.Boss = AITree.transform;
        }
    }
}
