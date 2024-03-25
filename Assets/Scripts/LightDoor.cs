using System;
using System.Collections;
using System.Collections.Generic;
using PixelCrushers;
using UnityEngine;
using UnityEngine.SceneManagement;

public class LightDoor : MonoBehaviour
{
    //public int sceneOffset = -1;
    public string sceneName;
    public string spawnpointNameInDestinationScene;
    private bool triggered = false;
    private int currentSceneIndex;
    private ScenePortal portal;
    
    void Start()
    {
        currentSceneIndex = SceneManager.GetActiveScene().buildIndex;
        ScenePortal portal = gameObject.GetComponentInChildren<ScenePortal>();
    }
    
    private void OnTriggerEnter2D(Collider2D other)
    {
        if (other.CompareTag("Player") && !triggered)
        {
            SceneManagerScript.i.ChangeSceneBySaveSystem(sceneName, spawnpointNameInDestinationScene);
            
            //SceneManagerScript.i.ChangeScene(currentSceneIndex + SceneOffset);
            triggered = true;
        }
            
        Debug.Log("Enter");
    }
}
