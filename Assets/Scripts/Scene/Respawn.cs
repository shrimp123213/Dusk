using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;

public class Respawn : MonoBehaviour
{
    public static Respawn i;
    
    public List<Vector3> respawnPoints = new List<Vector3>();

    private Character playerChr;
    private string sceneName;
    private GameObject player;
    
    private bool isRespawned = false;
    

    private void Awake()
    {
        if (i == null)
        {
            i = this;
        }  
        else
        {
            if(i != null)
            {
                Destroy(this.gameObject);
            }
        }
        DontDestroyOnLoad(this.gameObject);
        
        SceneManager.sceneLoaded += (scene, mode) => OnSceneLoaded();
    }

    private void OnSceneLoaded()
    {
        player = PlayerMain.i.gameObject;
        sceneName = SceneManager.GetActiveScene().name;
        if(sceneName == "TutorialScene")
        {
            RespawnPlayer();
        }
    }

    void Start()
    {
        
    }

    private void Update()
    {
        /*if(player==null)
        {
            player = GameObject.FindWithTag("Player");
            playerChr = player.GetComponent<Character>();
        }*/
        /*if(respawnPoints.Count > 0 && sceneName == "TutorialScene" && !isRespawned)
        {
            Invoke("RespawnPlayer", 0.01f); 
            isRespawned = true;
        }
        
        if(playerChr.isDead)
            isRespawned = false;*/
    }

    public void UpdateRespawnPoint(Vector3 newRespawnPoint,string _sceneName)
    {
        if (_sceneName == "TutorialScene")
        {
            //sceneName = _sceneName;
            respawnPoints.Add(newRespawnPoint);
        }
    }
    
    public void RespawnPlayer()
    {
        //SceneManagerScript.i.ChangeSceneBySaveSystem("TutorialScene", "Boss0_spawn");
        if (respawnPoints.Count > 0)
        {
            player.transform.position = respawnPoints[respawnPoints.Count - 1];
            respawnPoints.RemoveAt(respawnPoints.Count - 1);
        }
        else
        {
            //player.transform.position = new Vector3(-18.6f, -5f, 0);
        }
    }
    
}
