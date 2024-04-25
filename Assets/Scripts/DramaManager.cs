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
            foreach(var drama in dramaList)
            {
                if(drama.dramaIndex == 3)
                {
                    if(drama.dramaEnd)
                    {
                        dramaCatEnd = true;
                        //PlayerMain.i.state = PlayerMain.State.Human;
                        //PlayerMain.i.dramaCatMode = false;
                    }
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
    
    [Serializable]
    public class DramaData
    {
        public bool dramaEnd;
        public int dramaIndex;
    }

    
}
