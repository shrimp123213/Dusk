using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using Cinemachine;
using UnityEngine.InputSystem;

public class CameraTrack : MonoBehaviour
{
    public CinemachineVirtualCamera vCam;
    public float speed = 0.3f;
    public float camSize = 5f;

    public bool trackStart = false;
    
    public PlayerInput playInput;

    public Drama drama;
    
    public BackgroundParallax backgroundParallax;
    
    private float pathPosition = 0f;
    void Start()
    {
        vCam.m_Lens.OrthographicSize = camSize;
        playInput.enabled = false;
        vCam.enabled = true;
    }

    
    void Update()
    {
        if(trackStart)
            pathPosition += speed * Time.deltaTime;
        vCam.GetCinemachineComponent<CinemachineTrackedDolly>().m_PathPosition = pathPosition;

        if (pathPosition >= 1f)
        {
            vCam.gameObject.SetActive(false);
            backgroundParallax.enabled = true;
            drama.gameObject.SetActive(true);
            //playInput.enabled = true;
            //pathPosition = 0f;
        }

        if (drama.dramaEnd)
        {
            vCam.gameObject.SetActive(false);
            playInput.enabled = true;
            backgroundParallax.enabled = true;
        }
            
    }
}