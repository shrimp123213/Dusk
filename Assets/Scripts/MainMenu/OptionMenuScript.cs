using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using UnityEngine.Audio;

public class OptionMenuScript : MonoBehaviour
{
    public GameObject keySettingObj;
    //public GameObject settingTipObj;
    public GameObject soundTipObj;
    public Image[] settingTipImage;
    
    [Header("Panel")]
    public GameObject keySettingPanel;
    public GameObject soundSettingPanel;
    public GameObject mainMenuPanel;
    
    
    [Header("Button")]
    public Button keySettingButton;
    public Button soundSettingButton;
    public Button startGameButton;
    
    [Header("Tip Image")]
    public Sprite[] tipImageKeyBoard;
    public Sprite[] tipImageGamePad;
    
    [Header("Sound Slider")]
    public Slider musicSlider;
    public Slider audioSlider;
    
    [Header("Audio Mixer")]
    public AudioMixer mainMixer;
    
    [Header("Image Objects")]
    private Image keySettingImage;
    private Image soundTipImage;
    
    [SerializeField]
    private GameObject currentPanel;
    
    private GameObject optineMenuPanel;
    
    private void Start()
    {
        keySettingImage = keySettingObj.GetComponent<Image>();
        
        //settingTipImage = settingTipObj.GetComponent<Image>();
        
        soundTipImage = soundTipObj.GetComponent<Image>();
        
        if (InputDeviceUpdate.i.inputType == InputDeviceUpdate.InputType.Keyboard)
        {
            SetTipKeyBoard(0);
        }
        else if (InputDeviceUpdate.i.inputType == InputDeviceUpdate.InputType.Gamepad)
        {
            SetTipGamePad(0);
        }

        musicSlider.value = PlayerPrefs.GetFloat("MusicVolume");
        audioSlider.value = PlayerPrefs.GetFloat("AudioVolume");
    }

    private void OnEnable()
    {
        keySettingButton.Select();
        optineMenuPanel = this.gameObject;
        currentPanel = optineMenuPanel;
    }

    private void Update()
    {
        if (InputDeviceUpdate.i.inputType == InputDeviceUpdate.InputType.Keyboard)
        {
            SetTipKeyBoard(0);
        }
        else if (InputDeviceUpdate.i.inputType == InputDeviceUpdate.InputType.Gamepad)
        {
            SetTipGamePad(0);
        }
        
        if(InputDeviceUpdate.i.playerInput.actions["Back"].triggered)
        {
            Back();
        }

        if (keySettingPanel.activeSelf)
        {
            currentPanel = keySettingPanel;
        }
        else if (soundSettingPanel.activeSelf)
        {
            currentPanel = soundSettingPanel;
        }
        else if (optineMenuPanel.activeSelf && !keySettingPanel.activeSelf && !soundSettingPanel.activeSelf)
        {
            currentPanel = optineMenuPanel;
        }
        else if (mainMenuPanel.activeSelf)
        {
            currentPanel = mainMenuPanel;
        }
    }

    public void SetTipKeyBoard(int index)
    {
        /*foreach (var i in settingTipImage)
        {
            i.sprite = tipImageKeyBoard[0];
            i.SetNativeSize();
        }*/
        foreach (var i in settingTipImage)
        {
            i.sprite = tipImageKeyBoard[index];
            i.SetNativeSize();
        }
        
        soundTipImage.sprite = tipImageKeyBoard[index+1];
        
        keySettingImage.sprite = tipImageKeyBoard[index+2];
        
        
        soundTipImage.SetNativeSize();
    }
    
    public void SetTipGamePad(int index)
    {
        foreach (var i in settingTipImage)
        {
            i.sprite = tipImageGamePad[index];
            i.SetNativeSize();
        }
        
        soundTipImage.sprite = tipImageGamePad[index+1];
        
        keySettingImage.sprite = tipImageGamePad[index+2];
        
        soundTipImage.SetNativeSize();
    }
    
    public void KeySetting()
    {
        keySettingPanel.SetActive(true);
        soundSettingPanel.SetActive(false);
        
        currentPanel = keySettingPanel;
        foreach (var selectable in this.GetComponentsInChildren<Selectable>())
        {
            selectable.interactable = false;
        }
    }
    
    public void SoundSetting()
    {
        keySettingPanel.SetActive(false);
        soundSettingPanel.SetActive(true);
        
        currentPanel = soundSettingPanel;
        
        musicSlider.Select();
    }
    
    public void Back()
    {
        if (currentPanel == keySettingPanel || currentPanel == soundSettingPanel)
        {
            keySettingPanel.SetActive(false);
            soundSettingPanel.SetActive(false);
            foreach (var selectable in this.GetComponentsInChildren<Selectable>())
            {
                selectable.interactable = true;
            }
            keySettingButton.Select();
        }
        
        if (currentPanel == optineMenuPanel)
        {
            this.gameObject.SetActive(false);
            mainMenuPanel.SetActive(true);
            foreach (var selectable in mainMenuPanel.GetComponentsInChildren<Selectable>())
            {
                selectable.interactable = true;
            }
            startGameButton.Select();
        }
    }
    
    public void SetMusicVolume(float volume)
    {
        mainMixer.SetFloat("MusicVolume", volume);
        PlayerPrefs.SetFloat("MusicVolume", musicSlider.value);
        
        Debug.Log(volume);
    }
    
    public void SetAudioVolume(float volume)
    {
        mainMixer.SetFloat("AudioVolume", volume);
        PlayerPrefs.SetFloat("AudioVolume", audioSlider.value);
        
        Debug.Log(volume);
    }
}
