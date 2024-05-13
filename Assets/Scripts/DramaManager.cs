using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using PixelCrushers;
using UnityEngine.SceneManagement;

public class DramaManager : MonoBehaviour
{
    public static DramaManager i;
    
    public List<DramaData> dramaList;
    
    public bool hasDrama = false;
    public bool dramaCatEnd = false;
    public Drama openVideo;
    
    
    private void Awake()
    {
        if(i == null)
        {
            i = this;
        }
        else
        {
            if(i != null)
            {
                Destroy(gameObject);
            }
        }
        DontDestroyOnLoad(gameObject);
        
        SceneManager.sceneLoaded += (scene, mode) => OnSceneLoaded();
        dramaList = new List<DramaData>();
    }
    
    void Start()
    {
        /*PlayerMain.i.dramaCatMode = true;
        PlayerMain.i.Renderer.gameObject.SetActive(false);
        PlayerMain.i.CatRenderer.gameObject.SetActive(false);
        PlayerMain.i.dramaCatRenderer.gameObject.SetActive(true);*/
    }
    
    private void Update()
    {
        if(dramaList.Count > 0)
        {
            hasDrama = true;
        }
        else
        {
            hasDrama = false;
        }
        
        if(hasDrama)
        {
            for (int  index = 0; index < dramaList.Count; index++)
            {
                var drama = dramaList[index];
                if (drama is { dramaIndex: 3, dramaEnd: true })
                {
                    dramaCatEnd = true;
                    //PlayerMain.i.state = PlayerMain.State.Human;
                    //PlayerMain.i.dramaCatMode = false;
                }
                
                if (drama is { dramaIndex: 90, dramaEnd: true })
                {
                    SceneManagerScript.i.ChangeScene(0,1);
                }
            }
        }
    }

    void OnSceneLoaded()
    {
        if (!dramaCatEnd)
            PlayerMain.i.state = PlayerMain.State.Injured;
            //PlayerMain.i.dramaCatMode = true;
        
        if(dramaList.Count > 0)
        {
            hasDrama = true;
        }
        else
        {
            hasDrama = false;
        }

        if (dramaCatEnd)
        {
            PlayerMain.i.state = PlayerMain.State.Human;
            //PlayerMain.i.dramaCatMode = false;
        }

        openVideo = GameObject.Find("Video_Open").GetComponent<Drama>();
        if(openVideo.dramaEnd && openVideo != null)
            openVideo.gameObject.SetActive(false);
    }
    
    public void AddDramaData(DramaData newDrama)
    {
        foreach (var drama in dramaList)
        {
            if (drama.dramaIndex == newDrama.dramaIndex)
            {
                newDrama.dramaEnd = drama.dramaEnd;
                
                return;
            }
        }
        dramaList.Add(newDrama);
    }
    
    public bool CheckDrama(int dramaIndex)
    {
        foreach (var drama in dramaList)
        {
            if (drama.dramaIndex == dramaIndex)
            {
                return drama.dramaEnd;
            }
        }
        return false;
    }
    
    [Serializable]
    public class DramaData
    {
        public bool dramaEnd;
        public int dramaIndex;
    }

    
}
