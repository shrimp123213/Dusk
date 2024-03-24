using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using PixelCrushers.DialogueSystem;
using UnityEngine.InputSystem;
using PixelCrushers;
using InputDevice = PixelCrushers.InputDevice;

public class InputDeviceUpdate : MonoBehaviour
{
    public static InputDeviceUpdate i;
    
    private PlayerInput playerInput;

    private void Awake()
    {
        DontDestroyOnLoad(this.gameObject);
        i = this;
    }

    private void Start()
    {
        playerInput = GameObject.FindWithTag("Player").GetComponent<PlayerInput>();
        //InputDeviceManager.instance.inputDevice = playerInput.currentControlScheme == "Gamepad" ? InputDevice.Joystick : InputDevice.Keyboard;
        //Debug.Log("Input Device: " + InputDeviceManager.instance.inputDevice);
    }
    
    private void Update()
    {
        InputDeviceManager.instance.inputDevice = playerInput.currentControlScheme == "Gamepad" ? InputDevice.Joystick : InputDevice.Keyboard;
    }
}
