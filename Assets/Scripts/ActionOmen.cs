using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ActionOmen : MonoBehaviour
{
    public GameObject OmenSpawnPointWithTarget;
    public float liftTime = 1f;
    
    private bool hasTarget = false;
    void Start()
    {
        Destroy(gameObject, liftTime);
    }
    
    void FixedUpdate()
    {
        if(hasTarget)
            transform.position = OmenSpawnPointWithTarget.transform.position;
    }
    
    public void SetTarget(GameObject target)
    {
        OmenSpawnPointWithTarget = target;
        hasTarget = true;
    }
}
