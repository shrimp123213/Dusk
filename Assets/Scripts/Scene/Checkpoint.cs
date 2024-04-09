using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;

public class Checkpoint : MonoBehaviour
{
    public Respawn respawnScript; // 參考 Respawn 腳本的變量
    public string sceneName; // 場景名稱

    private void Start()
    {
        respawnScript = Respawn.i; // 取得 Respawn 腳本的實例
        sceneName = SceneManager.GetActiveScene().name; // 取得當前場景名稱
    }

    private void OnTriggerEnter2D(Collider2D other)
    {
        if (other.CompareTag("Player")) // 檢查碰撞的對象是否為玩家
        {
            respawnScript.UpdateRespawnPoint(transform.position,sceneName); // 更新重生點
            gameObject.SetActive(false); // 關閉檢查點
        }
    }
}
