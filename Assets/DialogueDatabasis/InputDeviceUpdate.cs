using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;
using PixelCrushers.DialogueSystem;
using UnityEngine.InputSystem;
using PixelCrushers;
using InputDevice = PixelCrushers.InputDevice;

public class InputDeviceUpdate : MonoBehaviour
{
    public static InputDeviceUpdate i;
    
    public PlayerInput playerInput;
    
    public InputType inputType = InputType.Gamepad;
    
    public GameObject dialogueManager;
    
    public InputType lastInputType;
    
    
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
        // 訂閱場景加載事件
        SceneManager.sceneLoaded += OnSceneLoaded;
        SceneManager.sceneUnloaded += arg0 => OnSceneUnloaded();
        
        DontDestroyOnLoad(this.gameObject);
    }

    private void Start()
    {
        if (playerInput == null)
        {
            playerInput = GameObject.FindWithTag("Player").GetComponent<PlayerInput>() ?? PlayerMain.i.GetComponent<PlayerInput>();

        }

        //playerInput.onControlsChanged += ctx => OnDeviceChanged();
        
        if(dialogueManager == null)
            dialogueManager = DialogueManager.instance.gameObject;
        
        //inputType = playerInput.currentControlScheme == "Gamepad" ? InputType.Gamepad : InputType.Keyboard;
        //OnDeviceChanged();
        //InputDeviceManager.instance.inputDevice = playerInput.currentControlScheme == "Gamepad" ? InputDevice.Joystick : InputDevice.Keyboard;
        //Debug.Log("Input Device: " + InputDeviceManager.instance.inputDevice);
    }
    
    private void Update()
    {
        OnDeviceChanged();
        
        //InputDeviceManager.instance.inputDevice = playerInput.currentControlScheme == "Gamepad" ? InputDevice.Joystick : InputDevice.Keyboard;

        //Debug.Log("Input Device: " + InputDeviceManager.instance.inputDevice);
    }
    
    public void OnDeviceChanged()
    {
        //playerInput = GameObject.FindWithTag("Player").GetComponent<PlayerInput>();
        
        inputType = playerInput.currentControlScheme == "Gamepad" ? InputType.Gamepad : InputType.Keyboard;
        if (dialogueManager != null)
        {
            InputDeviceManager.instance.inputDevice = inputType == InputType.Gamepad
                ? InputDevice.Joystick
                : InputDevice.Keyboard;
            DialogueLua.SetVariable("InputDevice", InputDeviceManager.instance.inputDevice.ToString());
            //DialogueLua.SetVariable("InputDevice", inputType == InputType.Gamepad ? "Joystick" : "Keyboard");
            //Debug.Log("Input Device: " + InputDeviceManager.instance.inputDevice);
            //Debug.Log("Input Device: " + DialogueLua.GetVariable("InputDevice").AsString);
        }
        
    }
    
    // 當場景加載時調用
    private void OnSceneLoaded(Scene scene, LoadSceneMode mode)
    {
        // 重新獲取playerInput
        if (playerInput == null)
        {
            playerInput = GameObject.FindWithTag("Player").GetComponent<PlayerInput>() ?? PlayerMain.i.GetComponent<PlayerInput>();
            
            //playerInput = PlayerMain.i.GetComponent<PlayerInput>();
        }
        if(dialogueManager == null)
            dialogueManager = DialogueManager.instance.gameObject;
        inputType = lastInputType;
        if(lastInputType == InputType.Gamepad)
            playerInput.SwitchCurrentControlScheme("Gamepad");
        else if(lastInputType == InputType.Keyboard)
            playerInput.SwitchCurrentControlScheme("Keyboard");
        
        InputDeviceManager.instance.inputDevice = lastInputType == InputType.Gamepad ? InputDevice.Joystick : InputDevice.Keyboard;
        //DialogueLua.SetVariable("InputDevice", lastInputType == InputType.Gamepad ? "Joystick" : "Keyboard");
        
        Debug.Log("Input Device: " + playerInput.currentControlScheme);
        //inputType = playerInput.currentControlScheme == "Gamepad" ? InputType.Gamepad : InputType.Keyboard;
        //playerInput.onControlsChanged += ctx => OnDeviceChanged();
        //OnDeviceChanged();
    }

    private void OnSceneUnloaded()
    {
        lastInputType = inputType;
        Debug.Log("Last Input Device: " + lastInputType);
    }
}
