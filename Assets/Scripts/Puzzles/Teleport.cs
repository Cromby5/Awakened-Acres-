using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Teleport : MonoBehaviour
{

    public Transform teleportTarget;

    public bool disableOnStart = true;
    
    public bool maze = false; 

    private void Start()
    {
        if (disableOnStart)
        GetComponent<BoxCollider>().enabled = false;
    }

    private void OnTriggerEnter(Collider other)
    {
        Debug.Log("Teleporting" + other.gameObject.name);
        if (other.CompareTag("Player"))
        {
            GameManager.player.MoveState(false, false);
            other.gameObject.transform.position = teleportTarget.position;
                if (maze)
                {
                    GameManager.switchSky.Daytime();
                }
            GameManager.player.MoveState(true, true);
        }
    }
}
