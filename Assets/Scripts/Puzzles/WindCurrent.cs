using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class WindCurrent : MonoBehaviour
{
    private PlayerMovement controller;

    [SerializeField] private int wind;
    private void OnTriggerEnter(Collider other)
    {
        controller = other.gameObject.GetComponent<PlayerMovement>();
    }
    private void OnTriggerStay(Collider other)
    {
        if (other.gameObject.CompareTag("Player"))
        {
            //other.gameObject.GetComponent<Rigidbody>().AddForce(transform.up * wind);
            controller.playerVelocity.y += wind * Time.deltaTime;
        }
    }
    private void OnTriggerExit(Collider other)
    {
        controller = null;
    }
}
