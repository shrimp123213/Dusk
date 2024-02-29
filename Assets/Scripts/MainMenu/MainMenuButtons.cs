using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class MainMenuButtons : MonoBehaviour
{
    public GameObject MainMenu;
    public GameObject OptionsMenu;
    public GameObject CreditsMenu;
    public GameObject QuitMenu;

    public void StartGame()
    {
        SceneManagerScript.i.ChangeScene("GameScene");
    }

    public void Options()
    {
        //MainMenu.SetActive(false);
        //OptionsMenu.SetActive(true);
        Debug.Log("Options");
    }

    public void Credits()
    {
        //MainMenu.SetActive(false);
        //CreditsMenu.SetActive(true);
        Debug.Log("Credits");
    }

    public void Quit()
    {
        //MainMenu.SetActive(false);
        //QuitMenu.SetActive(true);
        Debug.Log("Quit");
    }

    public void Back()
    {
        MainMenu.SetActive(true);
        OptionsMenu.SetActive(false);
        CreditsMenu.SetActive(false);
        QuitMenu.SetActive(false);
        Debug.Log("Back");
    }
}
