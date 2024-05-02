using System;
using System.Collections;
using System.Collections.Generic;
using DG.Tweening;
using PixelCrushers.DialogueSystem;
using UnityEngine;
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
        DialogueManager.instance.conversationEnded += OnConversationEnded;
    }

    private void OnConversationEnded(Transform t)
    {
        t.GetComponent<Drama>().dramaEnd = true;
        t.GetComponent<Drama>().newDrama.dramaEnd = true;
    }

    private void OnEnable()
    {
        if(!string.IsNullOrEmpty(musicName))
            MusicManager.i.Play(musicName,0,1,1);
        
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
                dramaEnd = true;
                newDrama.dramaEnd = true;
            }
        }
        
    }
}
