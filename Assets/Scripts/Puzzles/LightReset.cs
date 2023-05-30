using System.Collections;
using System.Collections.Generic;
using Unity.VisualScripting;
using UnityEngine;

public class LightReset : MonoBehaviour
{
    private lightTimer lightTimer;
    
    private void OnTriggerStay(Collider other)
    {
        if (other.gameObject.CompareTag("Player"))
        {
            GameManager.playerInteract.underLight = true;
            if (lightTimer != null)
            {
                lightTimer.SwitchStage(lightTimer.LightStage.Stage1);
            }
            else if (GameManager.playerInteract.IsLights(true))
            {
                lightTimer = lightTimer.GetLightTimer();
            }
        }
    }

    private void OnTriggerExit(Collider other)
    {
        if (other.gameObject.CompareTag("Player"))
        {
            lightTimer = null;
            GameManager.playerInteract.underLight = false;
        }
    }
}
