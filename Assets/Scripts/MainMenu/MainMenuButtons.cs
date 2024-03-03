using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using DG.Tweening;
using TMPro;

public class MainMenuButtons : MonoBehaviour
{
    public static MainMenuButtons i;
    
    public GameObject mainMenu;
    public GameObject optionsMenu;
    public GameObject creditsMenu;
    public GameObject quitMenu;

    public Image LOGO;
    
    public Button[] buttons;
    public Animator[] buttonAni;
    
    private Button currentButton;
    
    public void Awake()
    {
        mainMenu.SetActive(true);
        optionsMenu.SetActive(false);
        creditsMenu.SetActive(false);
        quitMenu.SetActive(false);
        
        buttonAni = new Animator[buttons.Length]; // 根據按鈕數量初始化動畫控制器陣列

        for (int i = 0; i < buttons.Length; i++)
        {
            buttonAni[i] = buttons[i].GetComponent<Animator>(); // 獲取每個按鈕的動畫控制器
        }
        
    }

    public void StartGame()
    {
        currentButton = buttons[0];
        
        ButtonPress(0);
        for (int i = 0; i < buttons.Length; i++)
        {
            buttonAni[i].enabled = false; // 當按鈕被點擊時，使其動畫控制器無效
            buttons[i].interactable = false; // 當按鈕被點擊時，使其無法再次被點擊
            //buttons[i].GetComponent<Image>().DOFade(0f, 1f); // 當按鈕被點擊時，使其逐漸變為透明
        }

        Invoke("ButtonFadeIn",.3f);
        Invoke("IntoGameScene",.7f);
        Debug.Log("Start Game");
    }

    public void Options()
    {
        //mainMenu.SetActive(false);
        //optionsMenu.SetActive(true);
        Debug.Log("Options");
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
        Debug.Log("Quit");
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
        // 當按鈕被點擊時，使其逐漸變為透明
        buttons[index].GetComponent<Image>().DOFade(0f, .2f);
        Image imgLeft = buttons[index].transform.GetChild(1).GetChild(0).GetComponent<Image>();
        Image imgRight = buttons[index].transform.GetChild(1).GetChild(1).GetComponent<Image>();
        imgLeft.DOFade(0f, .1f);// 使圖像逐漸變為透明
        imgRight.DOFade(0f, .1f);
        
        imgLeft.transform.DOMoveX(imgLeft.transform.position.x - .2f, .2f); // 使圖像向左移動
        imgRight.transform.DOMoveX(imgRight.transform.position.x + .2f, .2f); // 使圖像向右移動
        Debug.Log("Button:"+index+" Pressed");
    }

    void IntoGameScene()
    {
        SceneManagerScript.i.ChangeScene("GameScene");
    }

    void ButtonFadeIn()
    {
        for(int i = 0; i < buttons.Length; i++)
        {
            buttons[i].GetComponentInChildren<TextMeshProUGUI>().DOFade(0f, 1f); // 當按鈕被點擊時，使其逐漸變為透明
            
            //buttons[i].transform.GetChild(1).GetChild(0).GetComponent<Image>().DOFade(0f, .2f); // 當按鈕被點擊時，使其逐漸變為透明
            //buttons[i].transform.GetChild(1).GetChild(1).GetComponent<Image>().DOFade(0f, .2f); // 當按鈕被點擊時，使其逐漸變為透明
        }
        LOGO.DOFade(0f, 1f);
    }
}
