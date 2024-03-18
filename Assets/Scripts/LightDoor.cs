using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;

public class LightDoor : MonoBehaviour
{
    private bool triggered = false;
    private int currentSceneIndex;
    
    void Start()
    {
        currentSceneIndex = SceneManager.GetActiveScene().buildIndex;
    }
    
    private void OnTriggerEnter2D(Collider2D other)
    {
        if (other.CompareTag("Player") && !triggered)
        {
            SceneManagerScript.i.ChangeScene(currentSceneIndex - 1);
            triggered = true;
        }
            
        Debug.Log("Enter");
    }
}
