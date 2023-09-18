using Cinemachine;
using UnityEngine;

public class CameraManager : MonoBehaviour
{
    public static CameraManager i;

    public static Camera Main;

    public Camera main;

    public CinemachineTargetGroup Targets;

    public CinemachineVirtualCamera MainVCam;

    public CinemachineVirtualCamera FocusVCam;

    //public CustomConfiner MainVCamConfiner;

    public CinemachineImpulseSource CinemachineImpulseSource;

    public float ShakeDuration = 0.3f;

    public float ShakeAmplitude = 1.2f;

    public float ShakeFrequency = 1f;

    private float ShakeElapsedTime;

    private CinemachineBasicMultiChannelPerlin virtualCameraNoise;

    private void Awake()
    {
        i = this;
        Main = main;
        virtualCameraNoise = MainVCam.GetCinemachineComponent<CinemachineBasicMultiChannelPerlin>();
        //MainVCamConfiner.enabled = true;
    }

    public void SwitchCam(int target)
    {
        MainVCam.enabled = target == 0;
        FocusVCam.enabled = target == 1;
    }

    public void ResetTargets(Transform _T1, Transform _T2)
    {
        Targets.m_Targets = new CinemachineTargetGroup.Target[2];
        Targets.AddMember(_T1, 1.25f, 4f);
        Targets.AddMember(_T2, 1f, 4f);
    }

    public void GenerateImpulse(float _force = 1f)
    {
        CinemachineImpulseSource.GenerateImpulse(1f);
    }

    private void Update()
    {
        if (Input.GetKeyDown(KeyCode.Q))
        {
            GenerateImpulse();
        }
        if (virtualCameraNoise != null && ShakeElapsedTime > 0f)
        {
            ShakeElapsedTime -= Time.deltaTime;
            if (ShakeElapsedTime <= 0f)
            {
                virtualCameraNoise.m_AmplitudeGain = 0f;
            }
        }
    }
}
