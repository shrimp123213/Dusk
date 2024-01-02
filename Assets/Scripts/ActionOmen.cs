using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ActionOmen : MonoBehaviour
{
    public float liftTime = 1f;
    void Start()
    {
        Destroy(gameObject, liftTime);
    }
}
