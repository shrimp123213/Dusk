using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MapBound : MonoBehaviour
{
    private void OnTriggerEnter2D(Collider2D other)
    {
        if (other.CompareTag("Player"))
        {
            other.GetComponent<Transform>().position = new Vector3(55.7f, 0, 0);
            Debug.Log("Player is out of the map");
        }
    }
}
