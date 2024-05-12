using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MusicManager : MonoBehaviour
{
    public static MusicManager i;

    public Dictionary<string, AudioClip> Musics = new Dictionary<string, AudioClip>();

    public AudioSource MusicSource;
    public float volumeScale = 1f;

    private void Awake()
    {
        //MusicManager.i = this;
        AudioClip[] array = Resources.LoadAll<AudioClip>("Musics");
        foreach (AudioClip audioClip in array)
        {
            Musics.Add(audioClip.name, audioClip);
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

    public void Play(string soundName)
    {
        MusicSource.clip = Musics[soundName];
        MusicSource.Play();
    }

    public void Play(string soundName, float skipTimeTo)
    {
        MusicSource.clip = Musics[soundName];
        MusicSource.time = skipTimeTo;
        MusicSource.Play();
    }

    public void Play(string soundName, float FADE_TIME_SECONDS, float FADE_VOLUME)
    {
        Debug.Log("Play"+ soundName);
        StartCoroutine(FadeIn(FADE_TIME_SECONDS, FADE_VOLUME));

        MusicSource.clip = Musics[soundName];
        MusicSource.Play();

        //StartCoroutine(FadeOut(MusicSource.clip.length - skipTimeTo - FADE_TIME_SECONDS, 5f));
        StartCoroutine(Repeat(MusicSource.clip.length, soundName, FADE_TIME_SECONDS, FADE_VOLUME));
    }
    
    public void Play(string soundName, float skipTimeTo, float FADE_TIME_SECONDS, float FADE_VOLUME)
    {
        StartCoroutine(FadeIn(FADE_TIME_SECONDS, FADE_VOLUME));

        MusicSource.clip = Musics[soundName];
        MusicSource.time = skipTimeTo;
        MusicSource.Play();

        //StartCoroutine(FadeOut(MusicSource.clip.length - skipTimeTo - FADE_TIME_SECONDS, 5f));
        StartCoroutine(Repeat(MusicSource.clip.length - skipTimeTo, soundName, skipTimeTo, FADE_TIME_SECONDS, FADE_VOLUME));
    }

    IEnumerator Repeat(float delay, string soundName,float FADE_TIME_SECONDS, float FADE_VOLUME)
    {
        AudioClip currentClip = MusicSource.clip;
        yield return new WaitForSeconds(currentClip.length);
        if (MusicSource.clip == currentClip)
        {
            Play(soundName, FADE_TIME_SECONDS, FADE_VOLUME);
        }
    }
    
    IEnumerator Repeat(float delay, string soundName, float skipTimeTo, float FADE_TIME_SECONDS, float FADE_VOLUME)
    {
        AudioClip currentClip = MusicSource.clip;
        yield return new WaitForSeconds(currentClip.length - MusicSource.time);
        if (MusicSource.clip == currentClip)
        {
            Play(soundName, skipTimeTo, FADE_TIME_SECONDS, FADE_VOLUME);
        }
    }

    IEnumerator FadeOut(float delay, float FADE_TIME_SECONDS, float FADE_VOLUME)
    {
        yield return new WaitForSeconds(delay);
        var timeElapsed = 0f;

        while (MusicSource.volume > 0)
        {
            MusicSource.volume = Mathf.Lerp(FADE_VOLUME, 0, timeElapsed / FADE_TIME_SECONDS);
            timeElapsed += Time.deltaTime;
            yield return null;
        }
    }

    IEnumerator FadeIn(float FADE_TIME_SECONDS, float FADE_VOLUME)
    {
        var timeElapsed = 0f;

        MusicSource.volume = 0;
        while (MusicSource.volume < FADE_VOLUME)
        {
            MusicSource.volume = Mathf.Lerp(0, FADE_VOLUME, timeElapsed / FADE_TIME_SECONDS);
            timeElapsed += Time.deltaTime;
            yield return null;
        }
    }
    
    /*public void SetVolume(float volume)
    {
        volumeScale = volume;
    }*/
}
