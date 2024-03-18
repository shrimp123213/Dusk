using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;
using UnityEngine.UI;

public class SceneManagerScript : MonoBehaviour
{
    public static SceneManagerScript i;
    
    public GameObject FadePanel;
    public Image FadeImage;

    private void Awake()
    {
        SceneManagerScript.i = this;
    }

    public void ChangeScene(string SceneName)
    {
        StartCoroutine(ChangeSceneCoroutine(SceneName));
    }
    
    public void ChangeScene(int SceneIndex)
    {
        StartCoroutine(ChangeSceneCoroutine(SceneIndex));
    }
    

    public IEnumerator ChangeSceneCoroutine(string SceneName)
    {
        if(FadeImage == null || FadePanel == null)
        {
            Debug.LogError("FadeImage is null");
            yield break;
        }
        
        FadePanel.SetActive(true);
        FadeImage.color = new Color(0f, 0f, 0f, 0f);
        for (float i = 0f; i < 1f; i += Time.deltaTime)
        {
            FadeImage.color = new Color(0f, 0f, 0f, i);
            yield return null;
        }
        SceneManager.LoadScene(SceneName);
    }
    
    public IEnumerator ChangeSceneCoroutine(int SceneIndex)
    {
        if(FadeImage == null || FadePanel == null)
        {
            Debug.LogError("FadeImage is null");
            yield break;
        }
        
        FadePanel.SetActive(true);
        FadeImage.color = new Color(0f, 0f, 0f, 0f);
        for (float i = 0f; i < 1f; i += Time.deltaTime)
        {
            FadeImage.color = new Color(0f, 0f, 0f, i);
            yield return null;
        }
        SceneManager.LoadScene(SceneIndex);
    }
}
