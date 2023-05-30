using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class FadeImage : MonoBehaviour
{
    public Image img;

    public bool startFade;
    // Wont work past 1 for now, since alpha is 0-1
    public float timeToLoopFor = 1f;
    private void Awake()
    {
        if (img == null)
        {
            img = GetComponent<Image>();
        }
    }
    private void Start()
    {
        StartCoroutine(Fade(startFade));
    }

    public IEnumerator Fade(bool fadeAway)
    {
        // Fade from opaque to transparent
        if (fadeAway)
        {
            // Loop over 1 second backwards
            for (float i = timeToLoopFor; i >= 0; i -= Time.deltaTime)
            {
                // set color with i as alpha
                img.color = new Color(img.color.r, img.color.g, img.color.b, i);
                yield return null;
            }
        }
        // Fade from transparent to opaque
        else
        {
            // Loop over 1 second
            for (float i = 0; i <= timeToLoopFor; i += Time.deltaTime)
            {
                // Set color with i as alpha
                img.color = new Color(img.color.r, img.color.g, img.color.b, i);
                yield return null;
            }
        }
    }
}
