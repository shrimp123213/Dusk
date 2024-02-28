using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SoundManager : MonoBehaviour
{
    public static SoundManager i;

    public Dictionary<string, AudioClip> Sounds = new Dictionary<string, AudioClip>();

    public AudioSource SoundSource;

    private void Awake()
    {
        SoundManager.i = this;
        AudioClip[] array = Resources.LoadAll<AudioClip>("Sounds");
        foreach (AudioClip audioClip in array)
        {
            Sounds.Add(audioClip.name, audioClip);
            //Debug.Log("Add");
        }
    }

    public void PlaySound(string soundName)
    {
        SoundSource.PlayOneShot(Sounds[soundName]);
    }
}
