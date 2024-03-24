using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Entry : MonoBehaviour
{
    private void OnEnable()
    {
        //SceneManagerScript.i.ChangeScene("SanctuaryScene");
        //SceneManagerScript.i.ChangeSceneBySaveSystem("SanctuaryScene", "SpawnPoint");
    }
    
    public void ChangeScene()
    {
        //SceneManagerScript.i.ChangeScene("SanctuaryScene");
        SceneManagerScript.i.ChangeSceneBySaveSystem("SanctuaryScene", "SpawnPoint");
    }
}
