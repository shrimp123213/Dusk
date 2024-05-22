using System;
using System.Collections;
using System.Collections.Generic;
using DG.Tweening;
using PixelCrushers.DialogueSystem;
using UnityEngine;
using UnityEngine.InputSystem;
using UnityEngine.UI;

public class Drama : MonoBehaviour
{
    public bool dramaEnd = false;
    public int dramaIndex = 0;
    DramaManager.DramaData newDrama = new DramaManager.DramaData();
    public GameObject fadeImage;
    public string musicName;
    public bool isTrigger = false;
    private DialogueSystemTrigger dialogueSystemTrigger;

    private void Awake()
    {
        
    }

    void Start()
    {
        newDrama.dramaEnd = dramaEnd;
        newDrama.dramaIndex = dramaIndex;
        DramaManager.i.AddDramaData(newDrama);
        gameObject.SetActive(!dramaEnd);
        
        dialogueSystemTrigger = GetComponent<DialogueSystemTrigger>();
        
        DialogueManager.instance.conversationStarted += OnConversationStarted;
        DialogueManager.instance.conversationEnded += OnConversationEnded;
        
        if(!dialogueSystemTrigger)
            return;
        
        foreach (var dramaData in DramaManager.i.dramaList)
        {
            if (dramaData.dramaIndex == dramaIndex)
            {
                dramaEnd = dramaData.dramaEnd;
            }
        }
    }

    private void OnConversationStarted(Transform t)
    {
        PlayerMain.i.onConversation = true;
        PlayerMain.i.GetComponent<PlayerInput>().enabled = false;
        foreach (var enemy in GameObject.FindGameObjectsWithTag("Enemy"))
        {
            enemy.GetComponent<Character>().AITree.DisableBehavior(pause:true);
            enemy.GetComponent<Character>().StopMove();
        }
    }

    private void OnConversationEnded(Transform t)
    {
        t.GetComponent<Drama>().SetDramaEnd();
        PlayerMain.i.onConversation = false;
        PlayerMain.i.GetComponent<PlayerInput>().enabled = true;
        foreach (var enemy in GameObject.FindGameObjectsWithTag("Enemy"))
        {
            enemy.GetComponent<Character>().AITree.EnableBehavior();
        }
    }

    private void OnEnable()
    {
        if(!string.IsNullOrEmpty(musicName))
            MusicManager.i.Play(musicName,1,1);
        
        if(!DramaManager.i)
            return;
        
        foreach (var dramaData in DramaManager.i.dramaList)
        {
            if (dramaData.dramaIndex == dramaIndex)
            {
                dramaEnd = dramaData.dramaEnd;
            }
        }
    }


    void Update()
    {
        if (dramaEnd)
        {
            gameObject.SetActive(false);
        }
    }

    private void OnTriggerEnter2D(Collider2D other)
    {
        if(isTrigger)
        {
            if (other.CompareTag("Player"))
            {
                SetDramaEnd();
            }
        }
        
    }
    
    public void SetDramaEnd(bool end = true)
    {
        dramaEnd = end;
        newDrama.dramaEnd = end;
    }
}
