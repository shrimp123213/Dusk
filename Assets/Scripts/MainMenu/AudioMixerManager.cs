using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Audio;

public class AudioMixerManager : MonoBehaviour
{
    public static AudioMixerManager i;
    
    public AudioMixer audioMixer;
    
    private void Awake()
    {
        if(i == null)
        {
            i = this;
        }
        else
        {
            if(i != null)
            {
                Destroy(gameObject);
            }
            DontDestroyOnLoad(gameObject);
        }
    }

    private void Start()
    {
        GameObject.Find("MusicManager").GetComponent<AudioSource>().outputAudioMixerGroup = audioMixer.FindMatchingGroups("Music")[0];
        GameObject.Find("AudioManager").GetComponent<AudioSource>().outputAudioMixerGroup = audioMixer.FindMatchingGroups("Audio")[0];
        
        if(PlayerPrefs.HasKey("MusicVolume"))
        {
            audioMixer.SetFloat("MusicVolume", PlayerPrefs.GetFloat("MusicVolume"));
        }
        if(PlayerPrefs.HasKey("AudioVolume"))
        {
            audioMixer.SetFloat("AudioVolume", PlayerPrefs.GetFloat("AudioVolume"));
        }
    }
}
