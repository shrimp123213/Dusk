using System;
using UnityEngine;

public class Camcam : MonoBehaviour
{
    public static Camcam i;

    public Camera cam;

    public Transform Target;

    public Transform Boss;

    public Vector3 PosOverride;

    public bool UseOverride;

    public bool ChangeFOV;
    
    [Header("攝影機縮放控制")]
    public float minDistance = 5f; // 最小距離
    public float maxDistance = 10f; // 最大距離
    public float zoomSpeed = 5f; // 縮放速度
    public float minYPosition = -4.35f; // 攝影機最小Y軸位置
    public float maxYPosition = -1.35f; // 攝影機最大Y軸位置
    
    private Vector2 velo;
    private bool bossIsDead;
    [Range(-4.35f,-1.35f)]public float camY = -4.35f;

    private void Awake()
    {
        cam = GetComponent<Camera>();
        i = this;
    }

    private void Start()
    {
        Target = PlayerMain.i.transform;
    }

    private void FixedUpdate()
    {
        
    }

    private void LateUpdate()
    {
        if (UseOverride)
        {
            transform.position = Vector3.Lerp(transform.position, PosOverride, Time.fixedDeltaTime * 3f);
        }
        else if ((bool)Target)
        {
            if (Target.position.y > 7.5f)
            {
                transform.position = new Vector3(Mathf.SmoothDamp(transform.position.x, Target.position.x, ref velo.x, 0.125f), Mathf.Clamp(Mathf.SmoothDamp(transform.position.y, Target.position.y + 3.5f, ref velo.y, 0.375f), camY, 100f), -10f);
            }
            else
            {
                Vector3 newPos = new Vector3(Mathf.SmoothDamp(transform.position.x, Target.position.x, ref velo.x, 0.05f), Mathf.Clamp(Mathf.SmoothDamp(transform.position.y, Target.position.y, ref velo.y, 0.075f), camY, 100f), -10f);
                if (newPos.x != float.NaN && newPos.y != float.NaN && newPos.z != float.NaN)
                    transform.position = newPos;
            }
            if(ChangeFOV)
                SetFOV();
        }
    }
    
    public void SetFOV()
    {
        
        if (Boss != null )
        {
            bossIsDead=Boss.GetComponent<Boss1>().isDead;
            if (!this.bossIsDead)
            {
                // 計算玩家和BOSS之間的距離
                float distance = Vector3.Distance(Target.position, Boss.position);

                // 將距離映射到縮放範圍內
                float targetSize = Mathf.Clamp(distance, minDistance, maxDistance);

                // 平滑地改變攝影機的大小
                cam.orthographicSize = Mathf.Lerp(cam.orthographicSize, targetSize, Time.deltaTime * zoomSpeed);

                /*// 根據縮放大小調整攝影機的Y軸位置
                float newYPosition = Mathf.Lerp(minYPosition, maxYPosition,
                    Mathf.InverseLerp(minDistance, maxDistance, targetSize));
                Vector3 newPosition = transform.position;
                newPosition.y = newYPosition;
                transform.position = newPosition;*/
            }
            else
            {
                cam.orthographicSize = Mathf.Lerp(cam.orthographicSize, 5.0f, Time.deltaTime * zoomSpeed);
            }
        }
    }
}
