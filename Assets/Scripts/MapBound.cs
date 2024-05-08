using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MapBound : MonoBehaviour
{
    public Transform checkPoint;
    private Vector2 checkPointPos;
    
    void Start()
    {
        checkPointPos = checkPoint.position;
    }
    
    private void OnTriggerEnter2D(Collider2D other)
    {
        if (other.CompareTag("Player"))
        {
            other.GetComponent<Transform>().position = checkPointPos;
            Debug.Log("Player is out of the map");
        }
    }
}
