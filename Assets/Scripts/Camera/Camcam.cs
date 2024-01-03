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

    private Vector2 velo;

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
                transform.position = new Vector3(Mathf.SmoothDamp(transform.position.x, Target.position.x + Target.GetComponent<Character>().Facing * 1.125f, ref velo.x, 0.125f), Mathf.Clamp(Mathf.SmoothDamp(transform.position.y, Target.position.y + 3.5f, ref velo.y, 0.375f), -4.35f, 100f), -10f);
            }
            else
            {
                Vector3 newPos = new Vector3(Mathf.SmoothDamp(transform.position.x, Target.position.x + Target.GetComponent<Character>().Facing * 1.125f, ref velo.x, 0.125f), Mathf.Clamp(Mathf.SmoothDamp(transform.position.y, Target.position.y, ref velo.y, 0.075f), -4.35f, 100f), -10f);
                if (newPos.x != float.NaN && newPos.y != float.NaN && newPos.z != float.NaN)
                    transform.position = newPos;
            }
            if(ChangeFOV)
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
}
