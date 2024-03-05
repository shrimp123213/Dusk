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
            InputDeviceManager.RegisterInputAction("Pad_Back", controls.UI.Pad_Back);
            InputDeviceManager.RegisterInputAction("Pad_Submit", controls.UI.Pad_Submit);
            InputDeviceManager.RegisterInputAction("Pad_Movement", controls.UI.Pad_Movement);
            InputDeviceManager.RegisterInputAction("Key_Back", controls.UI.Key_Back);
            InputDeviceManager.RegisterInputAction("Key_Submit", controls.UI.Key_Submit);
            InputDeviceManager.RegisterInputAction("Key_Movement", controls.UI.Key_Movement);
            InputDeviceManager.RegisterInputAction("Horizontal", controls.UI.Horizontal);
            InputDeviceManager.RegisterInputAction("Vertical", controls.UI.Vertical);
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
            InputDeviceManager.UnregisterInputAction("Horizontal");
            InputDeviceManager.UnregisterInputAction("Vertical");
        }
    }
}
