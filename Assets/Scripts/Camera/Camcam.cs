using System.Collections.Generic;
using UnityEngine;

public class Camcam : MonoBehaviour
{
    public static Camcam i;

    public Camera cam;

    public Transform Target;

    public Transform Boss;

    public Vector3 PosOverride;

    public bool FadeIn;
    public bool BossShow;

    public bool ChangeFOV;
    
    [Header("攝影機縮放控制")]
    public float minDistance = 5f; // 最小距離
    public float maxDistance = 10f; // 最大距離
    public float zoomSpeed = 5f; // 縮放速度

    private Vector2 velo;

    public float bossShowingTime;

    public List<float> stageTime;
    public List<float> camSize;

    private bool spawnBlur;

    public bool FocusPlayer;

    private void Awake()
    {
        cam = GetComponent<Camera>();
        i = this;

        bossShowingTime = 0;
        FadeIn = true;
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
        if (FadeIn)
        {
            PosOverride = new Vector3(0, -3f, -10f);
            transform.position = Vector3.Lerp(transform.position, PosOverride, Time.fixedDeltaTime * 3f);
        }
        else if (BossShow)
        {
            BossShowing();
        }
        else if ((bool)Target)
        {
            if (FocusPlayer)
            {
                cam.orthographicSize = Mathf.Lerp(cam.orthographicSize, 3, Time.deltaTime * zoomSpeed * 6);

                Vector3 newPos = new Vector3(
                    Mathf.SmoothDamp(transform.position.x, Target.position.x, ref velo.x, 0.125f),
                    Mathf.Clamp(Mathf.SmoothDamp(transform.position.y, Target.position.y - 4f, ref velo.y, 0.075f), -4.35f, 100f),
                    -10f);
                if (newPos.x != float.NaN && newPos.y != float.NaN && newPos.z != float.NaN)
                    transform.position = newPos;
            }
            else if (Target.position.y > 7.5f)
            {
                transform.position = new Vector3(
                    Mathf.SmoothDamp(transform.position.x, Target.position.x + Target.GetComponent<Character>().Facing * 1.125f, ref velo.x, 0.125f),
                    Mathf.Clamp(Mathf.SmoothDamp(transform.position.y, Target.position.y + 3.5f, ref velo.y, 0.375f), -4.35f, 100f),
                    -10f);
            }
            else
            {
                Vector3 newPos = new Vector3(
                    Mathf.SmoothDamp(transform.position.x, Target.position.x + Target.GetComponent<Character>().Facing * 1.125f, ref velo.x, 0.125f), 
                    Mathf.Clamp(Mathf.SmoothDamp(transform.position.y, Target.position.y, ref velo.y, 0.075f), -4.35f, 100f),
                    -10f);
                if (newPos.x != float.NaN && newPos.y != float.NaN && newPos.z != float.NaN)
                    transform.position = newPos;
            }
            if(ChangeFOV && !FocusPlayer)
                SetFOV();
            
        }
    }
    
    public void SetFOV()
    {
        if (Boss != null)
        {
            // 計算玩家和BOSS之間的距離
            float distance = Vector3.Distance(Target.position, Boss.position );

            // 將距離映射到縮放範圍內
            float targetSize = Mathf.Clamp(distance, minDistance, maxDistance);

            // 平滑地改變攝影機的大小
            cam.orthographicSize = Mathf.Lerp(cam.orthographicSize, targetSize, Time.deltaTime * zoomSpeed);
        }
    }

    public void BossShowing()
    {
        if (bossShowingTime <= stageTime[0])
        {
            cam.orthographicSize = Mathf.Lerp(cam.orthographicSize, camSize[0], Time.deltaTime * zoomSpeed);

            PosOverride = Boss.position - Vector3.up * 2.5f;
            PosOverride.z = -10;
            transform.position = Vector3.Lerp(transform.position, PosOverride, Time.fixedDeltaTime * 2f);
        }
        else if (bossShowingTime <= stageTime[1])
        {
            cam.orthographicSize = Mathf.Lerp(cam.orthographicSize, camSize[1], Time.deltaTime * zoomSpeed);

            Boss = TransformUtility.FindTransform(Boss.parent, "Blade");
            PosOverride = Boss.position;
            PosOverride.z = -10;
            transform.position = Vector3.Lerp(transform.position, PosOverride, Time.fixedDeltaTime * 1f);
        }
        else if (bossShowingTime <= stageTime[2])
        {
            cam.orthographicSize = Mathf.Lerp(cam.orthographicSize, camSize[2], Time.deltaTime * zoomSpeed);

            PosOverride = Boss.position;
            PosOverride.z = -10;
            transform.position = Vector3.Lerp(transform.position, PosOverride, Time.fixedDeltaTime * 1f);
        }
        else if (bossShowingTime <= stageTime[3])
        {
            cam.orthographicSize = Mathf.Lerp(cam.orthographicSize, camSize[3], Time.deltaTime * zoomSpeed);

            PosOverride = Boss.position;
            PosOverride.z = -10;
            transform.position = Vector3.Lerp(transform.position, PosOverride, Time.fixedDeltaTime * 10f);
        }
        else if (bossShowingTime <= stageTime[4])
        {
            cam.orthographicSize = Mathf.Lerp(cam.orthographicSize, camSize[4], Time.deltaTime * zoomSpeed * 3);

            Boss = TransformUtility.FindTransform(Boss.parent, "Head");
            PosOverride = Boss.position;
            PosOverride.z = -10;
            transform.position = Vector3.Lerp(transform.position, PosOverride, Time.fixedDeltaTime * 3f);

            if (!spawnBlur)
            {
                spawnBlur = true; 
                AerutaDebug.i.SpawnPostBlurZoomOut(Boss.position - Vector3.up * 4f);
            }
        }
        else if (bossShowingTime <= stageTime[5])
        {
            cam.orthographicSize = Mathf.Lerp(cam.orthographicSize, camSize[5], Time.deltaTime * zoomSpeed * 1);

            PosOverride = Boss.position;
            PosOverride.z = -10;
            transform.position = Vector3.Lerp(transform.position, PosOverride, Time.fixedDeltaTime * 3f);
        }
        else if(bossShowingTime <= stageTime[6])
        {
            cam.orthographicSize = Mathf.Lerp(cam.orthographicSize, camSize[6], Time.deltaTime * zoomSpeed * 2);

            Boss = TransformUtility.FindTransform(Boss.parent, "Blade");
            PosOverride = Boss.position;
            PosOverride.z = -10;
            transform.position = Vector3.Lerp(transform.position, PosOverride, Time.fixedDeltaTime * 3f);
        }else
        {
            cam.orthographicSize = Mathf.Lerp(cam.orthographicSize, camSize[7], Time.deltaTime * zoomSpeed * 3);

            PosOverride = Boss.position;
            PosOverride.z = -10;
            transform.position = Vector3.Lerp(transform.position, PosOverride, Time.fixedDeltaTime * 10f);
        }

        bossShowingTime += Time.unscaledDeltaTime;
    }
}
