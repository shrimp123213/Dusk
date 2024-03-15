using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using PixelCrushers;
using PixelCrushers.DialogueSystem;

public class TipsSwitch : MonoBehaviour
{
    public GameObject padTips;
    public GameObject keyTips;

    private void Start()
    {
        DialogueLua.SetVariable("InputDevice", "Joystick");
    }

    private void Update()
    {
        if(InputDeviceManager.instance.inputDevice == InputDevice.Joystick)
        {
            SwitchTips(InputDevice.Joystick);
        }
        else
        {
            SwitchTips(InputDevice.Keyboard);
        }
    }

    public void SwitchTips(InputDevice device)
    {
        if(device == InputDevice.Joystick)
        {
            padTips.SetActive(true);
            keyTips.SetActive(false);
            DialogueLua.SetVariable("InputDevice", "Joystick");
        }
        else
        {
            padTips.SetActive(false);
            keyTips.SetActive(true);
            DialogueLua.SetVariable("InputDevice", "Keyboard");
        }
    }
    
}
