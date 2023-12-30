using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class AudioManager : MonoBehaviour
{
    public static AudioManager i;

    public Dictionary<string, AudioClip> Sounds = new Dictionary<string, AudioClip>();

    public AudioSource SoundSource;

    private void Awake()
    {
        AudioManager.i = this;
        AudioClip[] array = Resources.LoadAll<AudioClip>("");
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
