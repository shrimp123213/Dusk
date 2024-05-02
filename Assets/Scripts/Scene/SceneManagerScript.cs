using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;
using UnityEngine.UI;
using PixelCrushers;

public class SceneManagerScript : MonoBehaviour
{
    public static SceneManagerScript i;
    
    public GameObject FadePanel;
    public Image FadeImage;
    public string musicName;

    private void Awake()
    {
        SceneManagerScript.i = this;
        if(!string.IsNullOrEmpty(musicName))
            MusicManager.i.Play(musicName, 0f, 1f, 1f);
    }

    public void ChangeScene(string SceneName, float delay)
    {
        StartCoroutine(ChangeSceneCoroutine(SceneName,delay));
    }
    
    public void ChangeScene(int SceneIndex, float delay)
    {
        StartCoroutine(ChangeSceneCoroutine(SceneIndex,delay));
    }
    

    public void ChangeSceneBySaveSystem(string sceneName, string spawnpointNameInDestinationScene)
    {
        StartCoroutine(ChangeSceneCoroutineBySaveSystem(sceneName,spawnpointNameInDestinationScene));
    }
    public void ChangeSceneBySaveSystem(int sceneOffset, string spawnpointNameInDestinationScene)
    {
        StartCoroutine(ChangeSceneCoroutineBySaveSystem(sceneOffset,spawnpointNameInDestinationScene));
    }
    

    public IEnumerator ChangeSceneCoroutine(string SceneName, float delay)
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
        yield return delay;
        SceneManager.LoadScene(SceneName);
    }
    
    public IEnumerator ChangeSceneCoroutine(int SceneIndex, float delay)
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
        yield return delay;
        SceneManager.LoadScene(SceneIndex);
    }
    
    public IEnumerator ChangeSceneCoroutineBySaveSystem(string SceneName, string spawnpointNameInDestinationScene)
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
        SaveSystem.LoadScene(SceneName + "@" + spawnpointNameInDestinationScene);
        if(string.IsNullOrEmpty(spawnpointNameInDestinationScene))
            SceneManager.LoadScene(SceneName);
        Debug.Log(SceneName + "@" + spawnpointNameInDestinationScene);
    }
    
    public IEnumerator ChangeSceneCoroutineBySaveSystem(int sceneOffset, string spawnpointNameInDestinationScene)
    {
        int sceneIndex = SceneManager.GetActiveScene().buildIndex;
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
        SaveSystem.LoadScene(SceneManager.GetSceneByBuildIndex(sceneIndex + sceneOffset).name + "@" + spawnpointNameInDestinationScene);
    }
}
