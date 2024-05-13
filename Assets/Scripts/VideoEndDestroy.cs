using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using UnityEngine.Video;
using DG.Tweening;
using PixelCrushers.DialogueSystem;
using UnityEngine.SceneManagement;

public class VideoEndDestroy : MonoBehaviour
{
    public VideoPlayer videoPlayer;
    public RawImage rawImage;
    
    public CameraTrack cameraTrack;
    public GameObject drama_Start;
    
    public GameObject lightDoor;
    
    private bool conversationEnd = false;
    public bool videoEnd = false;
    
    public SceneName sceneName;
    
    private Drama selfDrama;
    
    public enum SceneName
    {
        Sanctuary,
        Tutorial
    }
    
    private void Start()
    {
        //gameObject.SetActive(false);
        //fadeImage.gameObject.SetActive(false);
        //rawImage.color = new Color(0, 0, 0, 0f);
        
        videoPlayer.loopPointReached += StopVideo;
        foreach (var dramaData in DramaManager.i.dramaList)
        {
            if(dramaData.dramaIndex == 4 && dramaData.dramaEnd)
            {
                lightDoor.SetActive(true);
            }
            
        }
        drama_Start?.SetActive(false);
        selfDrama = GetComponent<Drama>();
        PlayVideo();
    }

    private void OnEnable()
    {
        //rawImage.DOColor(new Color(1, 1, 1, 1), 1f).OnComplete(PlayVideo);
        
        //fadeImage.gameObject.SetActive(true);
        //fadeImage.color = new Color(0, 0, 0, 1f);
    }
    
    private void Update()
    {
        
    }
    

    public void PlayVideo()
    {
        videoPlayer.Play();
        PlayerMain.i.CanInput = false;

        switch (sceneName)
        {
            case SceneName.Sanctuary:
                break;
            case SceneName.Tutorial:
                cameraTrack.vCam.enabled = true;
                break;
        }
    }

    public void StopVideo(VideoPlayer vp)
    {
        switch (sceneName)
        {
            case SceneName.Sanctuary:
                StopVideoForSanctuary(vp);
                break;
            case SceneName.Tutorial:
                StopVideoForTutorial(vp);
                break;
        }
    }

    private void StopVideoForSanctuary(VideoPlayer vp)
    {
        videoEnd = true;
        //lightDoor.SetActive(true);
        
        //drama_4.SetActive(true);
        //fadeImage.color = new Color(0, 0, 0, 1f);
        rawImage.DOColor(new Color(0, 0, 0, 0f), 1f).OnComplete(() =>
        {
            gameObject.SetActive(false);
            PlayerMain.i.CanInput = true;
            DramaManager.i.dramaCatEnd = true;
            //fadeImage.gameObject.SetActive(false);
            lightDoor.SetActive(true);
        });
    }

    private void StopVideoForTutorial(VideoPlayer vp)
    {
        videoEnd = true;
        cameraTrack.trackStart = true;
        rawImage.DOColor(new Color(0, 0, 0, 0f), 1f).OnComplete(() =>
        {
            gameObject.SetActive(false);
            drama_Start.SetActive(true);
            selfDrama.SetDramaEnd();
        });
    }
}
