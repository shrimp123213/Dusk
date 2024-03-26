using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SoundManager : MonoBehaviour
{
    public static SoundManager i;

    public Dictionary<string, AudioClip> Sounds = new Dictionary<string, AudioClip>();

    public AudioSource SoundSource;
    public float volumeScale = 1f;

    private void Awake()
    {
        //SoundManager.i = this;
        AudioClip[] array = Resources.LoadAll<AudioClip>("Sounds");
        foreach (AudioClip audioClip in array)
        {
            Sounds.Add(audioClip.name, audioClip);
            //Debug.Log("Add");
        }
        
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

    public void PlaySound(string soundName)
    {
        SoundSource.PlayOneShot(Sounds[soundName]);
    }
}
