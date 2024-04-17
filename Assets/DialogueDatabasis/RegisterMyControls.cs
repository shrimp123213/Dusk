using System;
using System.Collections;
using System.Collections.Generic;
using BehaviorDesigner.Runtime.Tasks.Unity.UnityGameObject;
using UnityEngine;
using UnityEngine.InputSystem;
using PixelCrushers;
using PixelCrushers.DialogueSystem;

public class RegisterMyControls : MonoBehaviour
{
    protected static bool isRegistered = false;
    private bool didIRegister = false;
    private Keyboard keyboard;
    private Gamepad gamepad;
    private PlayerInputActions controls;
    private PlayerInput playerInput;
    

    void Awake()
    {
        controls = new PlayerInputActions();
        playerInput = GameObject.FindWithTag("Player").GetComponent<PlayerInput>();
        //InputDeviceManager.instance.inputDevice = playerInput.currentControlScheme == "Gamepad" ? InputDevice.Joystick : InputDevice.Keyboard;
        //Debug.Log("Input Device: " + InputDeviceManager.instance.inputDevice);
    }

    private void Update()
    {
        /*if(controls.FindAction("Submit").WasPressedThisFrame())
            Debug.Log("Action: " + controls.FindAction("Submit").name);
        if(controls.FindAction("MainMenuSubmit").WasPressedThisFrame())
            Debug.Log("Action: " + controls.FindAction("MainMenuSubmit").name);*/
    }

    void OnEnable()
    {
        if (!isRegistered)
        {
            isRegistered = true;
            didIRegister = true;
            controls.Enable();
            InputDeviceManager.RegisterInputAction("Pad_Back", controls.UI.Pad_Back);
            InputDeviceManager.RegisterInputAction("Pad_Submit", controls.UI.Pad_Submit);
            InputDeviceManager.RegisterInputAction("Pad_Movement", controls.UI.Pad_Movement);
            InputDeviceManager.RegisterInputAction("Key_Back", controls.UI.Key_Back);
            InputDeviceManager.RegisterInputAction("Key_Submit", controls.UI.Key_Submit);
            InputDeviceManager.RegisterInputAction("Key_Movement", controls.UI.Key_Movement);
            InputDeviceManager.RegisterInputAction("UI_Movement", controls.UI.UI_Movement);
            InputDeviceManager.RegisterInputAction("Submit", controls.UI.Submit);
            InputDeviceManager.RegisterInputAction("Back", controls.UI.Back);
            InputDeviceManager.RegisterInputAction("MainMenuSubmit", controls.UI.MainMenuSubmit);
        }
    }

    void OnDisable()
    {
        if (didIRegister)
        {
            isRegistered = false;
            didIRegister = false;
            controls.Disable();
            InputDeviceManager.UnregisterInputAction("Pad_Back");
            InputDeviceManager.UnregisterInputAction("Pad_Submit");
            InputDeviceManager.UnregisterInputAction("Pad_Movement");
            InputDeviceManager.UnregisterInputAction("Key_Back");
            InputDeviceManager.UnregisterInputAction("Key_Submit");
            InputDeviceManager.UnregisterInputAction("Key_Movement");
            InputDeviceManager.UnregisterInputAction("UI_Movement");
            InputDeviceManager.UnregisterInputAction("Submit");
            InputDeviceManager.UnregisterInputAction("Back");
            InputDeviceManager.UnregisterInputAction("MainMenuSubmit");
        }
    }
}
