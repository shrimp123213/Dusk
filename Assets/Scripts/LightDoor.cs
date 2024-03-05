using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class LightDoor : MonoBehaviour
{
    private bool triggered = false;
    
    private void OnTriggerEnter2D(Collider2D other)
    {
        if (other.CompareTag("Player") && !triggered)
        {
            SceneManagerScript.i.ChangeScene("GameScene");
            triggered = true;
        }
            
        Debug.Log("Enter");
    }
}
