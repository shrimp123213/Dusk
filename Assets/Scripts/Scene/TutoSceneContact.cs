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
    public Transform BossHealthBar;
    public TMP_Text BossName;
    public Image BossNameBackground;
    public int endFontSize;
    public Vector2 endPos;
    public Vector2 endSize;
    
    private Animator ani;
    private float speed;
    private bool triggered;
    private GameObject bossObj;
    private CinemachineTargetGroup targetGroup;
    
    void Start()
    {
        triggered = false;
        ani = AITree.GetComponentInChildren<Animator>();
        bossObj = AITree.gameObject;
        bossObj.SetActive(false);
        targetGroup = bossVCam.Follow.gameObject.GetComponent<CinemachineTargetGroup>();
        //bossObj.GetComponent<Rigidbody2D>().gravityScale = 0f;
    }

    private void Update()
    {
        //Debug.Log(ani.GetCurrentAnimatorClipInfo(0)[0].clip.name);
        if (ani.GetCurrentAnimatorClipInfo(0).Length > 0 &&
            ani.GetCurrentAnimatorClipInfo(0)[0].clip.name == "boss1_ap")
        {
            //bossObj.GetComponent<Rigidbody2D>().gravityScale = 1f;
            //targetGroup.m_Targets[0].weight = 0f;
            //bossVCam.gameObject.SetActive(true);
            //bossVCam.GetComponent<CinemachineCameraOffset>().m_Offset.y = 0f;
            //bossVCam.GetComponent<BossCamScript>().maxOffsetY = 0f;
            if (ani.GetCurrentAnimatorStateInfo(0).normalizedTime > 0.75f)
            {
                speed = 1f;
            }

            if (speed > 0f)
            {
                BossHealthBar.localScale = new Vector3(Mathf.MoveTowards(BossHealthBar.localScale.x, .75f, speed * Time.deltaTime), .75f, .75f);
                
                if (BossHealthBar.localScale.x >= .75f)
                {
                    targetGroup.m_Targets[0].weight = 1f;
                    bossVCam.GetComponent<CinemachineCameraOffset>().m_Offset.y = -3f;
                    bossVCam.GetComponent<BossCamScript>().maxOffsetY = -3f;
                    gameObject.SetActive(false);
                }
                PlayerMain.i.CanInput = true;

                if (BossName.text == "")
                {
                    BossName.text = "負傷星獸";
                    BossName.rectTransform.DOLocalMove(endPos, 0f);
                    BossName.rectTransform.DOSizeDelta(endSize, 0f);
                    BossName.fontSize = endFontSize;
                    BossNameBackground.color = new Color(0f, 0f, 0f, 0f);
                }
                    
            }
        }
    }

    private void OnTriggerEnter2D(Collider2D other)
    {
        if (other.CompareTag("Player") && !triggered)
        {
            triggered = true;
            //ani.Play("ap");
            bossVCam.gameObject.SetActive(true);
            
            AITree.enabled = true;
            bossObj.SetActive(true);
            
            PlayerMain.i.StopMove();
            PlayerMain.i.CanInput = false;
            
            
            //gameObject.SetActive(false);
        }
    }
}
