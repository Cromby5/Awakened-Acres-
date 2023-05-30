using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Audio;

[System.Serializable]
public class Sound
{
    public string name;
    public AudioClip clip;
    public AudioMixerGroup Mixer;

    [Range(0f, 1f)]
    public float volume = 1f;
    [Range(.1f, 3f)]
    public float pitch = 1f;

    [Range(0f, 1f)]
    public float spatialBlend = 0f;

    public bool loop = false;

    [HideInInspector]
    public AudioSource source;

}
