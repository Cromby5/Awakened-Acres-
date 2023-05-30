using UnityEngine;
using UnityEngine.Audio;

public class AudioManager : MonoBehaviour
{
    public Sound[] sounds;

    // Start is called before the first frame update
    void Awake()
    {
        if (GameManager.AudioManager != null && GameManager.AudioManager != this)
        {
            Destroy(this.gameObject);
        }
        else
        {
            GameManager.AudioManager = this;
        }
        DontDestroyOnLoad(this.gameObject);

        foreach (Sound s in sounds)
        {
            s.source = gameObject.AddComponent<AudioSource>();
            if (s.Mixer != null)
            {
                s.source.outputAudioMixerGroup = s.Mixer;
            }
            s.source.clip = s.clip;
            s.source.volume = s.volume;
            s.source.pitch = s.pitch;
            s.source.spatialBlend = s.spatialBlend;
            s.source.loop = s.loop;
        }

    }

    public void Play(string name)
    {
        Sound s = System.Array.Find(sounds, sound => sound.name == name);
        if (s == null)
        {
            Debug.LogWarning("Sound: " + name + " not found!");
            return;
        }
        // Temp until ideally i import fmod or refine a proper audio system, which would probably be overkill at this point but
        // it offers a lot of features I want to learn / use at some point
        if (s.name == "Farm Music")
        {
            Sound t = System.Array.Find(sounds, sound => sound.name == "Mirror Music");
            t.source.Stop();
        }
        
        if (s.name == "Mirror Music")
        {
            Sound t = System.Array.Find(sounds, sound => sound.name == "Farm Music");
            t.source.Stop();
        }
        
        s.source.Play();
    }

}
