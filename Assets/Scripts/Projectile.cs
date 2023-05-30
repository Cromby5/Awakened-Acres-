using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Projectile : MonoBehaviour
{
    [SerializeField] private float projectileSpeed; // Speed of project
    [SerializeField] private float secondsUntilDestory; // Timer for seconds until we destroy the bullet

    private enum ProjectileType
    {
        Fire,
        Water,
    }

    [SerializeField] private ProjectileType projectileType;

    // Start is called before the first frame update
    void Start()
    {
        // Get the rigidbody component from the object this script is attached to
        Rigidbody RigidBullet = GetComponent<Rigidbody>();
        // Set the velocity of this rigidbody to go forward at the speed of the bullet
        RigidBullet.velocity = transform.forward * projectileSpeed;
    }

    // Update is called once per frame
    void Update()
    {
        secondsUntilDestory -= Time.deltaTime;

        // Start to scale down the object to give the apperence of it fading out naturally 
        if (secondsUntilDestory < 1)
        {
            //transform.localScale *= secondsUntilDestory;  // Object scale is set to the amount of seconds 
        }
        // Destroy the bullet when we hit 0 or less seconds remaining on the timer
        if (secondsUntilDestory <= 0)
        {
            Destroy(gameObject);
        }
    }
    private void OnCollisionEnter(Collision collision)
    {
        if (collision.gameObject.CompareTag("IgnoreCol"))
            return;

        GameObject HitObject = collision.gameObject; // Assign our hit object to a gameobject variable
        if (HitObject.CompareTag("Flammable") && projectileType == ProjectileType.Fire) // If we hit something
        {
            HitObject.GetComponent<Flammable>().Burn(); // Call the burn function on the flammable script
        }
        else if (HitObject.CompareTag("Flammable") && projectileType == ProjectileType.Water)
        {
            HitObject.GetComponent<Flammable>().Extinguish();
        }
        Destroy(gameObject); // Destroys bullet
    }

    private void OnTriggerEnter(Collider other)
    {
        if (other.gameObject.CompareTag("IgnoreCol"))
            return;
        
        GameObject HitObject = other.gameObject; // Assign our hit object to a gameobject variable
        if (HitObject.CompareTag("Flammable") && projectileType == ProjectileType.Fire) // If we hit something
        {
            HitObject.GetComponentInChildren<Flammable>().Burn(); // Call the burn function on the flammable script
        }
        else if (HitObject.CompareTag("Flammable") && projectileType == ProjectileType.Water)
        {
            HitObject.GetComponentInChildren<Flammable>().Extinguish();
        }
        Destroy(gameObject); // Destroys bullet
    }
   
}
