using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class GenericDamage : MonoBehaviour
{
    [SerializeField] private int damage;
    
    private void OnTriggerStay(Collider other)
    {
        if (other.gameObject.CompareTag("Player"))
        {
            other.gameObject.GetComponent<AbilityBar>().AbilityBarDamage(damage);
            // knockback character controller
            //Vector3 pushDir = new Vector3(hit.moveDirection.x, 0, hit.moveDirection.z);
        }
    }

    private void OnCollisionStay(Collision collision)
    {
        if (collision.gameObject.CompareTag("Player"))
        {
            collision.gameObject.GetComponent<AbilityBar>().AbilityBarDamage(damage);
            // knockback character controller

        }
    }

    private void OnCollisionEnter(Collision collision)
    {
        if (collision.gameObject.CompareTag("Player"))
        {
            collision.gameObject.GetComponent<AbilityBar>().AbilityBarDamage(damage);
            // knockback character controller 

        }
    }
}
