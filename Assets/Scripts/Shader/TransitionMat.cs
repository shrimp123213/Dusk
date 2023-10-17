using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

[ExecuteInEditMode]

public class TransitionMat : MonoBehaviour
{
    public Material transitionMat;
    
    public Vector4 tilling = new Vector4(16f, 9f, 0f, 0f);
    [Range(0,1)] public float lerp = 0f;
    [Range(0,360)] public int rotator = 0;

    private void Awake()
    {
        transitionMat = GetComponent<Image>().material;
    }

    void Update()
    {
        transitionMat.SetVector("_Tilling",tilling);
        transitionMat.SetFloat("_Lerp",lerp);
        transitionMat.SetInt("_Rotator",rotator);
    }
}
