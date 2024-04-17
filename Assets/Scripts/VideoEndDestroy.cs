using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using UnityEngine.Video;
using DG.Tweening;
using PixelCrushers.DialogueSystem;

public class VideoEndDestroy : MonoBehaviour
{
    public VideoPlayer videoPlayer;
    public RawImage rawImage;
    public GameObject drama_4;
    public Image fadeImage;
    public GameObject lightDoor;
    
    private bool conversationEnd = false;
    
    private void Start()
    {
        gameObject.SetActive(false);
        //fadeImage.gameObject.SetActive(false);
        rawImage.color = new Color(0, 0, 0, 0f);
        videoPlayer.loopPointReached += StopVideo;
        foreach (var dramaData in DramaManager.i.dramaList)
        {
            if(dramaData.dramaIndex == 4 && dramaData.dramaEnd)
            {
                lightDoor.SetActive(true);
            }
            
        }
    }

    private void OnEnable()
    {
        rawImage.DOColor(new Color(1, 1, 1, 1), 1f).OnComplete(PlayVideo);
        fadeImage.gameObject.SetActive(true);
        fadeImage.color = new Color(0, 0, 0, 1f);
    }
    
    private void Update()
    {
        
    }
    
    public void PlayVideo()
    {
        videoPlayer.Play();
        PlayerMain.i.CanInput = false;
    }
    
    public void StopVideo(VideoPlayer vp)
    {
        drama_4.SetActive(true);
        //fadeImage.color = new Color(0, 0, 0, 1f);
        rawImage.DOColor(new Color(0, 0, 0, 0f), 1f).OnComplete(() =>
        {
            gameObject.SetActive(false);
            PlayerMain.i.CanInput = true;
            fadeImage.gameObject.SetActive(false);
            lightDoor.SetActive(true);
        });
    }
}
