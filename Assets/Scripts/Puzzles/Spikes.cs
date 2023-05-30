using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Spikes : MonoBehaviour
{

    [SerializeField] private int damage;

    [SerializeField] private float timeToRetract;
    [SerializeField] private float currentTime;

    private BoxCollider boxCollider;

    [SerializeField] private Transform up, hidden;

    private void Awake()
    {
        boxCollider = GetComponent<BoxCollider>();
    }
    void Start()
    {
        currentTime = 0;
    }

    void Update()
    {
        if (currentTime <= timeToRetract)
        {
            currentTime += Time.deltaTime;
        }
        else
        {
            if (transform.position == up.position)
            {
                transform.position = hidden.position;
                boxCollider.enabled = false;
            }
            else
            {
                transform.position = up.position;
                boxCollider.enabled = true;
            }
            currentTime = 0;
        }
    }

    private void OnTriggerStay(Collider other)
    {
        if (other.gameObject.CompareTag("Player"))
        {
            //other.gameObject.GetComponent<HealthSystem>().TakeDamage(damage);
        }
    }
}
