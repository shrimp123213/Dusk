using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using Cinemachine;

public class BossCamScript : MonoBehaviour
{
    public Camera mainCam;
    
    public CinemachineVirtualCamera bossVCam;
    public CinemachineCameraOffset bossCamOffset;

    public float minOffsetY = 0f;
    public float maxOffsetY = -4f;
    
    private float camSize;
    private float minbossVCamSize;
    private float maxbossVCamSize;
    
    private void Start()
    {
        mainCam = Camera.main;
        bossVCam = GetComponent<CinemachineVirtualCamera>();
        bossCamOffset = bossVCam.GetComponent<CinemachineCameraOffset>();
        
        minbossVCamSize = bossVCam.GetCinemachineComponent<CinemachineFramingTransposer>().m_MinimumOrthoSize;
        maxbossVCamSize = bossVCam.GetCinemachineComponent<CinemachineFramingTransposer>().m_MaximumOrthoSize;
    }
    
    private void Update()
    {
        camSize = mainCam.orthographicSize;
        bossCamOffset.m_Offset.y = Mathf.Lerp(maxOffsetY, minOffsetY, (camSize - minbossVCamSize) / (maxbossVCamSize - minbossVCamSize));

        if (AerutaDebug.i.Boss1.isDead)
        {
            gameObject.SetActive(false);
        }
        
        //Debug.Log(bossCamOffset.m_Offset.y);
    }
}
