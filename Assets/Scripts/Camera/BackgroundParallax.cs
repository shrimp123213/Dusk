using System.Collections;
using System.Collections.Generic;
using UnityEngine;
/// <summary>
/// Weiva Parallax
/// 2D 視差效果
/// 本組件背景視差效果是根據背景物件的世界座標 z 值來計算。默認參數中的背景數組第一個元素為最遠平面，
/// 既與攝像機同步的平面，該物件之間的背景根據 z 值進行視差計算。也可以單獨設定參數 synZ 強制設置最
/// 遠平面。大於最遠平面的 z 值將會反超攝像機移動。
/// weivain@qq.com
/// www.weiva.com
/// </summary>
public class BackgroundParallax : MonoBehaviour {

    [Header("背景圖片物件，Element 0 為與攝像機同步的背景層")]
    public Transform[] backgrounds;

    // 主攝像機
    private Transform cam;
    // 上一幀攝像機的位置
    private Vector3 previousCamPos;
    // 攝像機同步背景層的 z 值
    [Header("攝像機同步背景層 Z 值，若 0 為背景層 0")]
    public float synZ = 0f;
    [Header("偏移 x 係數")]
    public float parallaxScaleX = 1f;
    [Header("偏移 y 係數")]
    public float parallaxScaleY = 1f;


    // 初始化
    void Start ()
    {
        cam = Camera.main.transform;
        // 上一幀攝像機的位置
        previousCamPos = cam.position;
        if (synZ == 0 && null != backgrounds[0])
        {
            synZ = backgrounds[0].position.z;
        }
        if (synZ == 0)
        {
            synZ = 100f;
        }
        Debug.Log(backgrounds.Length);
    }

    // 每一幀執行
    void Update ()
    {
        // 獲得攝像機和上一幀的偏移值
        float parallax = previousCamPos.x - cam.position.x;

        // 攝像機偏移向量
        Vector3 camMove = cam.position - previousCamPos;
        camMove.x *= parallaxScaleX;
        camMove.y *= parallaxScaleY;

        // 同步背景
        for (int i = 0; i < backgrounds.Length; i++)
        {
            if (null == backgrounds[i]) continue;

            Vector3 targetToMove = backgrounds[i].position + camMove * (backgrounds[i].position.z / synZ);
            backgrounds[i].position = targetToMove;

        }

        // 更新上一幀攝像機的位置
        previousCamPos = cam.position;
    }
}