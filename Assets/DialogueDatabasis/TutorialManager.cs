using System;
using System.Collections;
using System.Collections.Generic;
using PixelCrushers;
using UnityEngine;
using UnityEngine.UI;
using UnityEngine.InputSystem;
using InputDevice = PixelCrushers.InputDevice;

public class TutorialManager : MonoBehaviour
{
    public GameObject tutorialPanel_Pad;
    public GameObject tutorialPanel_Keyboard;
    
    public InputActionAsset inputActionAsset;
    private InputActionMap playerAct;
    private InputActionMap UIAct;
    
    private bool isPanelActive = false;
    
    

    private void Start()
    {
        inputActionAsset = GameObject.FindWithTag("Player").GetComponent<PlayerInput>().actions;
        playerAct = inputActionAsset.FindActionMap("Player");
        UIAct = inputActionAsset.FindActionMap("UI");
        
    }
    
    void Update()
    {
        /*if (UIAct.FindAction("Pad_Submit").WasPressedThisFrame() && isPanelActive)
        {
            tutorialPanel_Pad.SetActive(false);
            tutorialPanel_Keyboard.SetActive(false);
            playerAct.Enable();
            isPanelActive = false;
            Debug.Log("Close Tutorial");
        }*/
    }

    public void ShowTutorialPanel()
    {
        playerAct.Disable();
        isPanelActive = true;
        if (InputDeviceManager.currentInputDevice == InputDevice.Joystick)
        {
            tutorialPanel_Pad.SetActive(true);
            tutorialPanel_Keyboard.SetActive(false);
        }
        else
        {
            tutorialPanel_Keyboard.SetActive(true);
            tutorialPanel_Pad.SetActive(false);
        }
    }
}
