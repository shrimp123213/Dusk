using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using DG.Tweening;
using TMPro;
using UnityEngine.Audio;
using UnityEngine.SceneManagement;

public class MainMenuButtons : MonoBehaviour
{
    public static MainMenuButtons i;
    
    [Header("Menu Objects")]
    public GameObject mainMenu;
    public GameObject optionsMenu;
    public GameObject creditsMenu;
    public GameObject quitMenu;
    
    [Header("Image Objects")]
    public Image LOGO;
    public Image FadePanel;

    public List<Button> buttons = new List<Button>();
    public Animator[] buttonAni;
    
    public string confirmSound;
    public string selectSound;
    public string cancelSound;
    
    [Header("Hint")]
    public Image C1;
    public Image C2;
    public Sprite[] hintSprite;
    
    [Header("Audio")]
    public AudioMixer mainMixer;
    
    //public TextMeshProUGUI hintText;
    
    private int currentButtonIndex;
    
    private GridLayoutGroup hintGridLayoutGroup;
    
    public void Awake()
    {
        i = this;
        mainMenu.SetActive(true);
        optionsMenu.SetActive(false);
        creditsMenu.SetActive(false);
        quitMenu.SetActive(false);
        
        buttonAni = new Animator[buttons.Count]; // 根據按鈕數量初始化動畫控制器陣列

        for (int i = 0; i < buttons.Count; i++)
        {
            buttonAni[i] = buttons[i].GetComponent<Animator>(); // 獲取每個按鈕的動畫控制器
        }
        //mainMixer.SetFloat("MusicVolume", PlayerPrefs.GetFloat("MusicVolume"));
        //mainMixer.SetFloat("AudioVolume", PlayerPrefs.GetFloat("AudioVolume"));
        
        //buttonSounds.Add("UI_Confirm"); // 將按鈕音效加入按鈕音效清單
        //buttonSounds.Add("UI_Select");
        //buttonSounds.Add("UI_Cancel");

        //MusicManager.i.Play("MainMenu", 0f, 1f, 1f);

        hintGridLayoutGroup = C1.gameObject.GetComponentInParent<GridLayoutGroup>();
    }

    private void Start()
    {
        MusicManager.i.Play("MainMenu", 0f, 1f, 1f);
    }

    private void Update()
    {
        
        if(InputDeviceUpdate.i.inputType == InputDeviceUpdate.InputType.Gamepad)
        {
            hintGridLayoutGroup.cellSize = new Vector2(169, 51);
            C1.sprite = hintSprite[0];
            C1.SetNativeSize();
            C2.sprite = hintSprite[1];
            C2.SetNativeSize();
            //hintText.text = "<sprite=>選擇      確認";
        }
        else if(InputDeviceUpdate.i.inputType == InputDeviceUpdate.InputType.Keyboard)
        {
            hintGridLayoutGroup.cellSize = new Vector2(180, 51);
            C1.sprite = hintSprite[2];
            C1.SetNativeSize();
            C2.sprite = hintSprite[3];
            C2.SetNativeSize();
            //hintText.text = "選擇      確認";
        }
        
    }

    private void OnEnable()
    {
        currentButtonIndex = 0;
        buttons[currentButtonIndex].Select();
    }

    public void StartGame()
    {
        currentButtonIndex = 0;
        ButtonPress(currentButtonIndex);
        for (int i = 0; i < buttons.Count; i++)
        {
            buttonAni[i].enabled = false; // 當按鈕被點擊時，使其動畫控制器無效
            buttons[i].interactable = false; // 當按鈕被點擊時，使其無法再次被點擊
            //buttons[i].GetComponent<Image>().DOFade(0f, 1f); // 當按鈕被點擊時，使其逐漸變為透明
        }
        buttons[currentButtonIndex].GetComponentInChildren<TextMeshProUGUI>().DOFade(0f, 2f);
        buttons.Remove(buttons[currentButtonIndex]);
        
        for(int i = 0; i < buttons.Count; i++)
        {
            buttons[i].GetComponentInChildren<TextMeshProUGUI>().DOFade(0f, 2f); // 當按鈕被點擊時，使其逐漸變為透明
            
            //buttons[i].transform.GetChild(1).GetChild(0).GetComponent<Image>().DOFade(0f, .2f); // 當按鈕被點擊時，使其逐漸變為透明
            //buttons[i].transform.GetChild(1).GetChild(1).GetComponent<Image>().DOFade(0f, .2f); // 當按鈕被點擊時，使其逐漸變為透明
        }
        
        Invoke("ButtonFadeIn",.7f);
        Invoke("IntoGameScene",1.3f);
        Debug.Log("Start Game");
    }

    public void Options()
    {
        //mainMenu.SetActive(false);
        optionsMenu.SetActive(true);
        optionsMenu.GetComponent<Image>().DOFade(1, 1f);
        
        // 播放音效
        SoundManager.i.PlaySound(confirmSound);
        Debug.Log("Options");
        foreach (var selectable in mainMenu.GetComponentsInChildren<Selectable>())
        {
            //selectable.interactable = false;
        }
    }

    public void Credits()
    {
        //mainMenu.SetActive(false);
        //creditsMenu.SetActive(true);
        Debug.Log("Credits");
    }

    public void Quit()
    {
        //mainMenu.SetActive(false);
        //quitMenu.SetActive(true);
        
        currentButtonIndex = 3;
        ButtonPress(currentButtonIndex);
        for (int i = 0; i < buttons.Count; i++)
        {
            buttonAni[i].enabled = false; // 當按鈕被點擊時，使其動畫控制器無效
            buttons[i].interactable = false; // 當按鈕被點擊時，使其無法再次被點擊
            //buttons[i].GetComponent<Image>().DOFade(0f, 1f); // 當按鈕被點擊時，使其逐漸變為透明
            buttons[i].GetComponentInChildren<TextMeshProUGUI>().DOFade(0f, .2f);
        }
        Invoke("ButtonFadeIn",.3f);
        FadePanel.gameObject.SetActive(true);
        FadePanel.DOFade(1, 1f);
        Debug.Log("Quit");
        
        Invoke("CloseGame",.7f);
    }

    public void Back()
    {
        mainMenu.SetActive(true);
        optionsMenu.SetActive(false);
        creditsMenu.SetActive(false);
        quitMenu.SetActive(false);
        Debug.Log("Back");
    }

    public void ButtonPress(int index)
    {
        Image imgLeft = buttons[index].transform.GetChild(1).GetChild(0).GetComponent<Image>();
        Image imgRight = buttons[index].transform.GetChild(1).GetChild(1).GetComponent<Image>();
        Image buttonImg = buttons[index].GetComponent<Image>();
        
        // 當按鈕被點擊時，使其逐漸變為透明
        buttonImg.DOFade(0f, .2f);
        
        imgLeft.DOFade(0f, .1f);// 使圖像逐漸變為透明
        imgRight.DOFade(0f, .1f);
        
        imgLeft.transform.DOMoveX(imgLeft.transform.position.x - .2f, .2f); // 使圖像向左移動
        imgRight.transform.DOMoveX(imgRight.transform.position.x + .2f, .2f); // 使圖像向右移動
        
        // 播放音效
        SoundManager.i.PlaySound(confirmSound);
        
        Debug.Log("Button:"+index+" Pressed");
    }

    void IntoGameScene()
    {
        SceneManagerScript.i.ChangeScene(SceneManager.GetActiveScene().buildIndex + 1);
    }

    void ButtonFadeIn()
    {
        /*for(int i = 0; i < buttons.Count; i++)
        {
            buttons[i].GetComponentInChildren<TextMeshProUGUI>().DOFade(0f, .2f); // 當按鈕被點擊時，使其逐漸變為透明
            
            //buttons[i].transform.GetChild(1).GetChild(0).GetComponent<Image>().DOFade(0f, .2f); // 當按鈕被點擊時，使其逐漸變為透明
            //buttons[i].transform.GetChild(1).GetChild(1).GetComponent<Image>().DOFade(0f, .2f); // 當按鈕被點擊時，使其逐漸變為透明
        }*/
        LOGO.DOFade(0f, 2f);
    }
    
    private void CloseGame()
    {
        //MusicManager.i.MusicSource.volume = 0;
        Application.Quit();
    }
}
