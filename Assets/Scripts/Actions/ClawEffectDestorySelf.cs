using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ClawEffectDestorySelf : MonoBehaviour
{
    private Animator Ani;

    void Start()
    {
        Ani = GetComponent<Animator>();
    }

    void Update()
    {
        if (Ani.GetCurrentAnimatorStateInfo(0).normalizedTime >= 1)
            Destroy(gameObject);
    }
}
