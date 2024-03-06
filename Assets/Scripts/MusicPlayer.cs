using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MusicPlayer : MonoBehaviour
{
    public string musicName;
    void Start()
    {
        MusicManager.i.Play(musicName, 0, 0.1f, 1f);
    }
}
