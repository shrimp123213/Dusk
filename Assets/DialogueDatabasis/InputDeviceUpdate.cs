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
    
    public PlayerInput playerInput;
    
    public InputType inputType;
    
    public enum InputType
    {
        None,
        Keyboard,
        Gamepad
    }

    private void Awake()
    {
        if (i == null)
        {
            i = this;
        }  
        else
        {
            if(i != null)
            {
                Destroy(this.gameObject);
            }
        }
        //DontDestroyOnLoad(this.gameObject);
    }

    private void Start()
    {
        //playerInput = GameObject.FindWithTag("Player").GetComponent<PlayerInput>();
        //InputDeviceManager.instance.inputDevice = playerInput.currentControlScheme == "Gamepad" ? InputDevice.Joystick : InputDevice.Keyboard;
        //Debug.Log("Input Device: " + InputDeviceManager.instance.inputDevice);
    }
    
    private void Update()
    {
        OnDeviceChanged();
        /*playerInput = GameObject.FindWithTag("Player").GetComponent<PlayerInput>();
        inputType = playerInput.currentControlScheme == "Gamepad" ? InputType.Gamepad : InputType.Keyboard;
        if (GameObject.Find("Dialogue Manager") != null)
        {
            InputDeviceManager.instance.inputDevice = playerInput.currentControlScheme == "Gamepad"
                ? InputDevice.Joystick
                : InputDevice.Keyboard;
            DialogueLua.SetVariable("InputDevice", InputDeviceManager.instance.inputDevice.ToString());
        }*/
        //InputDeviceManager.instance.inputDevice = playerInput.currentControlScheme == "Gamepad" ? InputDevice.Joystick : InputDevice.Keyboard;

        //Debug.Log("Input Device: " + InputDeviceManager.instance.inputDevice);
    }
    
    public void OnDeviceChanged()
    {
        playerInput = GameObject.FindWithTag("Player").GetComponent<PlayerInput>();
        inputType = playerInput.currentControlScheme == "Gamepad" ? InputType.Gamepad : InputType.Keyboard;
        if (GameObject.Find("Dialogue Manager") != null)
        {
            InputDeviceManager.instance.inputDevice = playerInput.currentControlScheme == "Gamepad"
                ? InputDevice.Joystick
                : InputDevice.Keyboard;
            DialogueLua.SetVariable("InputDevice", InputDeviceManager.instance.inputDevice.ToString());
        }
        
    }
}
