using System;
using System.Collections;
using System.Collections.Generic;
using TMPro;
using UnityEngine;
using DG.Tweening;
using UnityEngine.InputSystem;
using PixelCrushers;
using InputDevice = PixelCrushers.InputDevice;
using UnityEngine.UI;

public class ShowTips : MonoBehaviour
{
    public TextMeshProUGUI tipText;
    public Image tipBackgroundPanel;
    public string tip;
    
    private PlayerInput playerInput;
    
    [Header("Tip類型")]
    public TipType tipType;
    
    public enum TipType
    {
        Tip,
        Input
    }
    
    [Header("自適應輸入")]
    public InputType inputType;
    public enum InputType
    {
        None,
        Keyboard,
        Gamepad
    }
    
    
    void Start()
    {
        tipText.color = new Color(1, 1, 1, 0);
        tipBackgroundPanel.color = new Color(0, 0, 0, 0);
    }
    
    void Update()
    {
        inputType = InputDeviceManager.instance.inputDevice == InputDevice.Joystick ? InputType.Gamepad : InputType.Keyboard;
    }
    
    void ShowTip(string tip)
    {
        switch (tipType)
        {
            case TipType.Tip:
                tipText.text = tip;
                break;
            case TipType.Input:
                switch (inputType)
                {
                    case InputType.None:
                        tipText.text = tip;
                        break;
                    case InputType.Keyboard:
                        tipText.text = "<sprite=15>" + tip;
                        break;
                    case InputType.Gamepad:
                        tipText.text = "<sprite=4>" + tip;
                        break;
                }
                break;
        }
        
        tipText.DOFade(1, 1);
        tipBackgroundPanel.DOFade(1, 1);
        Debug.Log("Show tip");
    }
    
    void HideTip()
    {
        tipText.DOFade(0, 1);
        tipBackgroundPanel.DOFade(0, 1);
        Debug.Log("Hide tip");
    }

    private void OnTriggerEnter2D(Collider2D other)
    {
        if (other.CompareTag("Player"))
        {
            ShowTip(tip);
        }
    }
    
    private void OnTriggerExit2D(Collider2D other)
    {
        if (other.CompareTag("Player"))
        {
            HideTip();
        }
    }
}
