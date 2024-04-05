using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using Cinemachine;

public class BossCamScript : MonoBehaviour
{
    public Camera mainCam;
    
    public CinemachineVirtualCamera bossVCam;
    public CinemachineCameraOffset bossCamOffset;
    
    private float camSize;
    private float minOffsetY;
    private float maxOffsetY;
    private float minbossVCamSize;
    private float maxbossVCamSize;
    
    private void Start()
    {
        mainCam = Camera.main;
        bossVCam = GetComponent<CinemachineVirtualCamera>();
        bossCamOffset = bossVCam.GetComponent<CinemachineCameraOffset>();
        
        minOffsetY = 0f;
        maxOffsetY = -3f;
        minbossVCamSize = bossVCam.GetCinemachineComponent<CinemachineFramingTransposer>().m_MinimumOrthoSize;
        maxbossVCamSize = bossVCam.GetCinemachineComponent<CinemachineFramingTransposer>().m_MaximumOrthoSize;
    }
    
    private void Update()
    {
        camSize = mainCam.orthographicSize;
        bossCamOffset.m_Offset.y = Mathf.Lerp(maxOffsetY, minOffsetY, (camSize - minbossVCamSize) / (maxbossVCamSize - minbossVCamSize));
        //Debug.Log(bossCamOffset.m_Offset.y);
    }
}
