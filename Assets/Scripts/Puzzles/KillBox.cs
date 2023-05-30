using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class KillBox : MonoBehaviour
{
    [SerializeField]
    private Transform target; // Where the player will spawn after 'death'
    [SerializeField] private SwitchSky sky; // The player object

    private void OnTriggerEnter(Collider other)
    {
        if (other.gameObject.CompareTag("Player"))
        {
            other.gameObject.GetComponent<CharacterController>().enabled = false; // Disable the player's controller (Required for transform movement)
            other.gameObject.transform.position = GameManager.Spawn.position; // Move the player to the target position
            other.gameObject.GetComponent<CharacterController>().enabled = true; // Re-enable the controller

        }
    }
   
}
