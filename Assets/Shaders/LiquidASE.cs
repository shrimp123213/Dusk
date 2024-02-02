using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class LiquidASE : MonoBehaviour
{
    public Material mat;
    public Image img;

    public float waveHeight;
    private void Start()
    {
        //mat = gameObject.GetComponent<Renderer>().material;
        //img = gameObject.GetComponent<Image>();
    }

    void Update()
    {
        waveHeight = img.fillAmount;
        mat.SetFloat("_WaveHeight", waveHeight);
    }
}
