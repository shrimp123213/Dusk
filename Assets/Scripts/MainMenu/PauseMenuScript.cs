using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using UnityEngine.Audio;
using UnityEngine.InputSystem;

public class PauseMenuScript : MonoBehaviour
{
    public GameObject keySettingObj;
    //public GameObject settingTipObj;
    public GameObject soundTipObj;
    [Header("SettingTipImage")]
    public Image[] C1;
    public Image[] C2;
    public Image[] C3;
    
    [Header("Panel")]
    public GameObject keySettingPanel;
    public GameObject soundSettingPanel;
    public GameObject creditsPanel;
    
    
    [Header("Button")]
    public Button keySettingButton;
    public Button soundSettingButton;
    public Button creditsButton;
    
    [Header("Hint GridLayoutGroup")]
    public GridLayoutGroup[] hintGridLayoutGroup;
    
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

    //玩家Input
    public InputActionAsset inputActionAsset;
    
    [SerializeField]
    private GameObject currentPanel;
    
    private GameObject optineMenuPanel;
    
    

    private void Awake()
    {
        
    }

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

        if(PlayerPrefs.HasKey("MusicVolume"))
            musicSlider.value = PlayerPrefs.GetFloat("MusicVolume");
        else
        {
            musicSlider.value = 0;
            PlayerPrefs.SetFloat("MusicVolume", 0);
        }
        if(PlayerPrefs.HasKey("AudioVolume"))
            audioSlider.value = PlayerPrefs.GetFloat("AudioVolume");
        else
        {
            audioSlider.value = 0;
            PlayerPrefs.SetFloat("AudioVolume", 0);
        }

        
    }

    private void OnEnable()
    {
        keySettingButton.Select();
        optineMenuPanel = this.gameObject;
        currentPanel = optineMenuPanel;
        
        foreach (var selectable in this.GetComponentsInChildren<Selectable>())
        {
            selectable.interactable = true;
            selectable.animator.enabled = true;
        }
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

        Dictionary<GameObject, Func<bool>> panelConditions = new Dictionary<GameObject, Func<bool>>
        {
            { keySettingPanel, () => keySettingPanel.activeSelf },
            { soundSettingPanel, () => soundSettingPanel.activeSelf },
            { creditsPanel, () => creditsPanel.activeSelf },
            { optineMenuPanel, () => optineMenuPanel.activeSelf && !keySettingPanel.activeSelf && !soundSettingPanel.activeSelf },
        };

        foreach (var panel in panelConditions)
        {
            if (panel.Value.Invoke())
            {
                currentPanel = panel.Key;
                break;
            }
        }
    }

    public void SetTipKeyBoard(int index)
    {
        /*foreach (var i in settingTipImage)
        {
            i.sprite = tipImageKeyBoard[0];
            i.SetNativeSize();
        }*/
        foreach (var i in C1)
        {
            i.sprite = tipImageKeyBoard[index];
            i.SetNativeSize();
        }
        foreach (var i in C2)
        {
            i.sprite = tipImageKeyBoard[index+1];
            i.SetNativeSize();
        }
        foreach (var i in C3)
        {
            i.sprite = tipImageKeyBoard[index+2];
            i.SetNativeSize();
        }
        foreach (var gridLayoutGroup in hintGridLayoutGroup)
        {
            if (gridLayoutGroup != null)
            {
                gridLayoutGroup.cellSize = new Vector2(180, 51);
            }
        }
        
        soundTipImage.sprite = tipImageKeyBoard[index+3];
        
        keySettingImage.sprite = tipImageKeyBoard[index+4];
        
        
        soundTipImage.SetNativeSize();
    }
    
    public void SetTipGamePad(int index)
    {
        foreach (var i in C1)
        {
            i.sprite = tipImageGamePad[index];
            i.SetNativeSize();
        }
        foreach (var i in C2)
        {
            i.sprite = tipImageGamePad[index+1];
            i.SetNativeSize();
        }
        foreach (var i in C3)
        {
            i.sprite = tipImageGamePad[index+2];
            i.SetNativeSize();
        }
        
        foreach (var gridLayoutGroup in hintGridLayoutGroup)
        {
            gridLayoutGroup.cellSize = new Vector2(130, 55);
        }
        
        soundTipImage.sprite = tipImageGamePad[index+3];
        
        keySettingImage.sprite = tipImageGamePad[index+4];
        
        soundTipImage.SetNativeSize();
    }
    
    public void KeySetting()
    {
        keySettingPanel.SetActive(true);
        soundSettingPanel.SetActive(false);
        creditsPanel.SetActive(false);
        
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
        creditsPanel.SetActive(false);
        
        currentPanel = soundSettingPanel;
        
        musicSlider.Select();
    }

    public void ShowCredits()
    {
        keySettingPanel.SetActive(false);
        soundSettingPanel.SetActive(false);
        creditsPanel.SetActive(true);

        currentPanel = creditsPanel;
        foreach (var selectable in this.GetComponentsInChildren<Selectable>())
        {
            selectable.interactable = false;
        }
    }
    
    public void Back()
    {
        if (currentPanel != optineMenuPanel)
        {
            foreach (var selectable in this.GetComponentsInChildren<Selectable>())
            {
                selectable.animator.Rebind();
                selectable.animator.Update(0);
                selectable.interactable = true;
            }
            
            keySettingPanel.SetActive(false);
            soundSettingPanel.SetActive(false);
            creditsPanel.SetActive(false);
            
            keySettingButton.Select();
        }
        /*{
            keySettingPanel.SetActive(false);
            soundSettingPanel.SetActive(false);
            creditsPanel.SetActive(false);
            foreach (var selectable in this.GetComponentsInChildren<Selectable>())
            {
                selectable.interactable = true;
            }
            keySettingButton.Select();
        }*/
        
        if (currentPanel == optineMenuPanel)
        {
            foreach (var selectable in this.GetComponentsInChildren<Selectable>())
            {
                // 停止或重置動畫
                selectable.animator.Rebind();
                selectable.animator.Update(0);
                
                // 然後設置為不可互動
                selectable.interactable = false;
            }
            
            this.gameObject.SetActive(false);
            inputActionAsset.FindActionMap("UI").Disable();
            inputActionAsset.FindActionMap("Player").Enable();
            Time.timeScale = 1f;
            currentPanel = null;
            AerutaDebug.i.isPause = false;
            Debug.Log("Resume Game");
        }
    }
    
    public void SetMusicVolume(float volume)
    {
        mainMixer.SetFloat("MusicVolume", volume);
        PlayerPrefs.SetFloat("MusicVolume", musicSlider.value);
        PlayerPrefs.Save();
        Debug.Log(volume);
    }
    
    public void SetAudioVolume(float volume)
    {
        mainMixer.SetFloat("AudioVolume", volume);
        PlayerPrefs.SetFloat("AudioVolume", audioSlider.value);
        PlayerPrefs.Save();
        Debug.Log(volume);
    }

    public void QuitGame()
    {
        Application.Quit();
    }
}
