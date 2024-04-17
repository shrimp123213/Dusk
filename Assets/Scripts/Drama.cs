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
    }

    private void OnEnable()
    {
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
        dramaEnd = true;
        newDrama.dramaEnd = true;
    }
}
