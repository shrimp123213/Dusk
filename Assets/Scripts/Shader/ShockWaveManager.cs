using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;


public class ShockWaveManager : MonoBehaviour
{
    [SerializeField] private float _shockWaveTime = 0.75f;
    

    
    private Coroutine _shockWaveCoroutine;
    
    private Material _material;
    
    private static int _waveDistanceFromCenterId = Shader.PropertyToID("_WaveDistanceFromCenter");

    private void Awake()
    {
        _material = GetComponent<SpriteRenderer>().material;
    }

    private void OnEnable()
    {
        CallShockWave();
    }

    public void CallShockWave()
    {
        _shockWaveCoroutine = StartCoroutine(ShockWaveAction(-0.1f,1f));
    }
    
    private IEnumerator ShockWaveAction(float startPos, float endPos)
    {
        _material.SetFloat(_waveDistanceFromCenterId, startPos);
        float lerpedAmount = 0f;
        
        float elapsedTime = 0f;
        while (elapsedTime < _shockWaveTime)
        {
            elapsedTime += Time.deltaTime;
            lerpedAmount = Mathf.Lerp(startPos, endPos, elapsedTime / _shockWaveTime);
            _material.SetFloat(_waveDistanceFromCenterId, lerpedAmount);
            yield return null;
        }
    }
}
