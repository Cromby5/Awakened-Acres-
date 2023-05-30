using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class DarkDangerZone : MonoBehaviour
{
    [SerializeField] private bool inDanger = false;

    [SerializeField] private float timeToKill;
    [SerializeField] private float timeLeft;

    [SerializeField] private float fogIntensity = 0.12f;
    [SerializeField] private float fogToAddPerSecond = 0.005f;

    void Start()
    {
        timeLeft = timeToKill;
    }
    void Update()
    {
        if (inDanger)
        {
            if (timeLeft > 0)
            {
                timeLeft -= Time.deltaTime;
                RenderSettings.fogDensity += fogToAddPerSecond * Time.deltaTime;
            }
            else if (timeLeft <= 0)
            {
                GameManager.LevelManager.TorchCheckPoint();
                RenderSettings.fogDensity = fogIntensity;
                inDanger = false;
            }
        }
        else
        {
            timeLeft = timeToKill;
            RenderSettings.fogDensity = fogIntensity;
        }
    }
    private void OnTriggerEnter(Collider other)
    {
        if (other.gameObject.CompareTag("Player"))
        {
            inDanger = true;
        }
    }
    
    private void OnTriggerStay(Collider other)
    {
        if (other.gameObject.CompareTag("Player"))
        {
            if (GameManager.playerInteract.IsLights(true) || GameManager.playerInteract.underLight == true)
            {
                inDanger = false;
            }
            else
            {
                inDanger = true;
            }
        }
    }

    private void OnTriggerExit(Collider other)
    {
        if (other.gameObject.CompareTag("Player"))
        {
            inDanger = false;
        }
    }
}
