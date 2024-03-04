using System.Collections;
using System.Collections.Generic;
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
    

    void Awake()
    {
        controls = new PlayerInputActions();
    }

    void OnEnable()
    {
        if (!isRegistered)
        {
            isRegistered = true;
            didIRegister = true;
            controls.Enable();
            InputDeviceManager.RegisterInputAction("Back", controls.UI.Back);
            InputDeviceManager.RegisterInputAction("Submit", controls.UI.Submit);
            InputDeviceManager.RegisterInputAction("Pad_Movement", controls.UI.Pad_Movement);
            InputDeviceManager.RegisterInputAction("Key_Movement", controls.UI.Key_Movement);
        }
    }

    void OnDisable()
    {
        if (didIRegister)
        {
            isRegistered = false;
            didIRegister = false;
            controls.Disable();
            InputDeviceManager.UnregisterInputAction("Back");
            InputDeviceManager.UnregisterInputAction("Submit");
            InputDeviceManager.UnregisterInputAction("Pad_Movement");
            InputDeviceManager.UnregisterInputAction("Key_Movement");
        }
    }
}
