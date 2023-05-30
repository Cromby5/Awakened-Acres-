using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public enum HeartState { Empty, Half, Full }

public class HealthHeart : MonoBehaviour
{
    private Image image;
    public Sprite full, half, empty;
 
    private void Awake()
    {
        image = GetComponent<Image>();
    }
    
    public void SetHeart(HeartState state)
    {
        switch (state)
        {
            case HeartState.Full:
                image.sprite = full;
                break;
            case HeartState.Half:
                image.sprite = half;
                break;
            case HeartState.Empty:
                image.sprite = empty;
                break;
        }
    }
}
