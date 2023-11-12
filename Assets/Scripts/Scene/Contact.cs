using System;
using System.Collections;
using System.Collections.Generic;
using BehaviorDesigner.Runtime;
using UnityEngine;

public class Contact : MonoBehaviour
{
    public Animator[] fences;

    public BehaviorTree AITree;
    private Animator ani;


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
                
            }
            if (ani.GetCurrentAnimatorStateInfo(0).normalizedTime > 480f / 501f)
            {
                AITree.GetComponent<Character>().HitEffect.HitStun = .01f;
                gameObject.SetActive(false);
            }
;
        }
        
    }

    private void OnTriggerEnter2D(Collider2D other)
    {
        if (other.CompareTag("Player"))
        {
            AITree.enabled = true;
            //ani.Play("boss1-1_ST_start");
            AerutaDebug.i.StartGameTime = Time.unscaledTime;
        }
    }
}
