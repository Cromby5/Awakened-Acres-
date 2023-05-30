using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Audio;

public class SetVolume : MonoBehaviour
{
    public AudioMixer Mixer;
    public void SetMasterLevel(float sliderValue)
    {
        Mixer.SetFloat("Master", Mathf.Log10(sliderValue) * 20);
    }

    public void SetMusicLevel(float sliderValue)
    {
        Mixer.SetFloat("Music", Mathf.Log10(sliderValue) * 20);
    }
    public void SetSFXLevel(float sliderValue)
    {
        Mixer.SetFloat("SFX", Mathf.Log10(sliderValue) * 20);
    }

}
