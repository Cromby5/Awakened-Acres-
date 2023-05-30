using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ResourceHarvest : SelectBase
{
    public GameObject resource;
    
    [SerializeField] private GameObject remains;
    [SerializeField] private GameObject thisResource;

    private Vector3 resourceSpawnOffset = new Vector3(0.5f, 1, 0.5f);

    // Start is called before the first frame update
    void Start()
    {
    
    }

    public override void Interact()
    {
        if (!remains.activeInHierarchy)
        {
            // Spawn collectable resource
            Instantiate(resource, transform.position + resourceSpawnOffset, resource.transform.rotation);

            remains.SetActive(true);
            thisResource.SetActive(false);
            Destroy(thisResource);
        }
        else if (remains.activeInHierarchy)
        {
            Destroy(gameObject);
        }
    }

}