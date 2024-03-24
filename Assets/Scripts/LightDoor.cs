using System;
using System.Collections;
using System.Collections.Generic;
using PixelCrushers;
using UnityEngine;
using UnityEngine.SceneManagement;

public class LightDoor : MonoBehaviour
{
    public int SceneOffset = -1;
    
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
            SceneManagerScript.i.ChangeSceneBySaveSystem("TutorialScene", "Tip_Entry");
            
            //SceneManagerScript.i.ChangeScene(currentSceneIndex + SceneOffset);
            triggered = true;
        }
            
        Debug.Log("Enter");
    }
}
