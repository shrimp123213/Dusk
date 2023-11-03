using System;
using System.Collections;
using System.Collections.Generic;
using BehaviorDesigner.Runtime;
using UnityEngine;

public class Contact : MonoBehaviour
{
    public Animator[] fences;

    public BehaviorTree AITree;
    
    private BoxCollider2D contactCol;
    
    
    void Start()
    {
        contactCol = GetComponent<BoxCollider2D>();
        AITree.DisableBehavior();
    }


    private void OnTriggerEnter2D(Collider2D other)
    {
        if (other.CompareTag("Player"))
        {
            fences[0].Play("FenceUp");
            fences[1].Play("FenceUp");
            AITree.EnableBehavior();
            
        }
    }
}
