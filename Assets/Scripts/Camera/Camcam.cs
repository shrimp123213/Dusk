using UnityEngine;

public class Camcam : MonoBehaviour
{
    public static Camcam i;

    public Camera cam;

    public Transform Target;

    public Vector3 PosOverride;

    public bool UseOverride;

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
                transform.position = new Vector3(Mathf.SmoothDamp(transform.position.x, Target.position.x, ref velo.x, 0.125f), Mathf.Clamp(Mathf.SmoothDamp(transform.position.y, Target.position.y + 3.5f, ref velo.y, 0.375f), -3f, 100f), -10f);
            }
            else
            {
                Vector3 newPos = new Vector3(Mathf.SmoothDamp(transform.position.x, Target.position.x, ref velo.x, 0.05f), Mathf.Clamp(Mathf.SmoothDamp(transform.position.y, Target.position.y, ref velo.y, 0.075f), -3f, 100f), -10f);
                if (newPos.x != float.NaN && newPos.y != float.NaN && newPos.z != float.NaN)
                    transform.position = newPos;
            }
        }
    }
}
