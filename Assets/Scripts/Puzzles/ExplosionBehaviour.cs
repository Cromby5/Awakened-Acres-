using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ExplosionBehaviour : MonoBehaviour
{
    public float secondsToExist; // Seconds for our effect to exist for
    float secondsAlive; // Tracking how long has this object been alive for

    void Start()
    {
        secondsAlive = 0;
    }

    void FixedUpdate()
    {
        secondsAlive += Time.deltaTime; // Incrementing by time in seconds every fixedupdate

        float lifeFraction = secondsAlive / secondsToExist; // Gives a fraction that will be used to smooth out the lerp.
        Vector3 maxScale = Vector3.one * 8; // The max scale this explosion will be 
        transform.localScale = Vector3.Lerp(Vector3.zero, maxScale, lifeFraction); // Starting at 0 we scale up smoothly to the max size over the time remaining as a fraction 

        if (secondsAlive >= secondsToExist)
        {
            Destroy(gameObject); // Destroys this object
        }
    }

    private void OnTriggerEnter(Collider other)
    {
        Debug.Log(other.gameObject);
        if (other.gameObject.CompareTag("Rock"))
        {
            Debug.Log("Rock Destroyed");
            Destroy(other.gameObject);
        }
    }

}
