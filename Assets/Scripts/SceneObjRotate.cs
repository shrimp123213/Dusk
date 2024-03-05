using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SceneObjRotate : MonoBehaviour
{
    public float rotateAngle = -40f;
    public float rotateTime = 2f;
    
    public float timer = 7f;
    
    // 設定不同的初始計時器值，以實現錯開的效果
    public float initialTimerOffset = 0f;
    
    //private GameObject sceneObj;
    private float rotateCooldown;
    void Start()
    {
        rotateCooldown = rotateCooldown = timer + initialTimerOffset;
    }
    
    void Update()
    {
        if(timer > 0)
        {
            timer -= Time.deltaTime;
        }
        else
        {
            Rotate();
            timer = rotateCooldown;
        }
    }
    
    public void Rotate()
    {
        StartCoroutine(RotateCoroutine());
    }
    
    public IEnumerator RotateCoroutine()
    {
        float startAngle = transform.eulerAngles.z;
        float endAngle = startAngle + rotateAngle;
        float time = 0f;
        while (time < rotateTime)
        {
            time += Time.deltaTime;
            float angle = Mathf.Lerp(startAngle, endAngle, time / rotateTime);
            transform.eulerAngles = new Vector3(0f, 0f, angle);
            yield return null;
        }
    }
}
