using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Splight : MonoBehaviour
{
    private Animator animator;
    void Start()
    {
        animator = GetComponent<Animator>();
        //if(animator.GetCurrentAnimatorStateInfo(0).normalizedTime >= 1.0f)
            Destroy(gameObject,0.5f);
    }

    
    void Update()
    {
        
    }
}
