using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Rock : MonoBehaviour
{
    private void OnDestroy()
    {
        //Animation stuff?
        
    }

    private void OnCollisionEnter(Collision collision)
    {
        Debug.Log("Collision" + collision.gameObject.name);
        if (collision.gameObject.name == "Expolosion")
        {
            Destroy(gameObject);
        }
    }

    private void OnTriggerEnter(Collider other)
    {
        Debug.Log("Trigger" + other.gameObject.name);
        if (other.gameObject.name == "Expolosion")
        {
            Destroy(gameObject);
        }
    }
}
