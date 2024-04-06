using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using BehaviorDesigner.Runtime;
using TMPro;
using UnityEngine.UI;
using DG.Tweening;
using Spine.Unity;
using Cinemachine;

public class TutoSceneContact : MonoBehaviour
{
    public CinemachineVirtualCamera bossVCam;
    public BehaviorTree AITree;
    
    private bool triggered;
    
    void Start()
    {
        triggered = false;
    }

    private void OnTriggerEnter2D(Collider2D other)
    {
        if (other.CompareTag("Player") && !triggered)
        {
            triggered = true;
            bossVCam.gameObject.SetActive(true);
            AITree.enabled = true;
            gameObject.SetActive(false);
        }
    }
}
