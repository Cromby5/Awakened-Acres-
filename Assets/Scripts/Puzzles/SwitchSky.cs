using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SwitchSky : MonoBehaviour
{
    public bool isDay = true;
    public GameObject blockcade;
    public GameObject blockcade2;

    private void Awake()
    {
        GameManager.switchSky = this;
    }
    void OnTriggerEnter(Collider other)
    {
        if (isDay)
        {
            NightTime();
        }
        else if (!isDay && !blockcade.activeSelf)
        {
            Daytime();
        }
    }
    
    public void Daytime()
    {
        RenderSettings.skybox = GameManager.instance.skybox_a;
        DynamicGI.UpdateEnvironment();
        RenderSettings.fog = false;
        isDay = true;
        blockcade.SetActive(false);
        blockcade2.SetActive(true);
    }

    public void NightTime()
    {
        RenderSettings.skybox = GameManager.instance.skybox_b;
        DynamicGI.UpdateEnvironment();
        RenderSettings.fog = true;
        RenderSettings.fogDensity = 0.12f;
        isDay = false;
        blockcade.SetActive(true);
        blockcade2.SetActive(false);
    }
}
