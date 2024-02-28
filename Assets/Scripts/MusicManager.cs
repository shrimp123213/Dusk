using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MusicManager : MonoBehaviour
{
    public static MusicManager i;

    public Dictionary<string, AudioClip> Musics = new Dictionary<string, AudioClip>();

    public AudioSource MusicSource;

    private void Awake()
    {
        MusicManager.i = this;
        AudioClip[] array = Resources.LoadAll<AudioClip>("Musics");
        foreach (AudioClip audioClip in array)
        {
            Musics.Add(audioClip.name, audioClip);
            //Debug.Log("Add");
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

    public void Play(string soundName, float skipTimeTo, float FADE_TIME_SECONDS)
    {
        StartCoroutine(FadeIn(FADE_TIME_SECONDS));

        MusicSource.clip = Musics[soundName];
        MusicSource.time = skipTimeTo;
        MusicSource.Play();

        //StartCoroutine(FadeOut(MusicSource.clip.length - skipTimeTo - FADE_TIME_SECONDS, 5f));
        StartCoroutine(Repeat(MusicSource.clip.length - skipTimeTo, soundName, skipTimeTo, FADE_TIME_SECONDS));
    }

    IEnumerator Repeat(float delay, string soundName, float skipTimeTo, float FADE_TIME_SECONDS)
    {
        yield return new WaitForSeconds(delay);
        Play(soundName, skipTimeTo, FADE_TIME_SECONDS);
    }

    IEnumerator FadeOut(float delay, float FADE_TIME_SECONDS)
    {
        yield return new WaitForSeconds(delay);
        var timeElapsed = 0f;

        while (MusicSource.volume > 0)
        {
            MusicSource.volume = Mathf.Lerp(1, 0, timeElapsed / FADE_TIME_SECONDS);
            timeElapsed += Time.deltaTime;
            yield return null;
        }
    }

    IEnumerator FadeIn(float FADE_TIME_SECONDS)
    {
        var timeElapsed = 0f;

        MusicSource.volume = 0;
        while (MusicSource.volume < 1)
        {
            MusicSource.volume = Mathf.Lerp(0, 1, timeElapsed / FADE_TIME_SECONDS);
            timeElapsed += Time.deltaTime;
            yield return null;
        }
    }
}
