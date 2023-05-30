using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ItemSpawner : MonoBehaviour
{

    [SerializeField] private bool isActive;

    // Start is called before the first frame update
    public GameObject prefab;
    
    private List<Transform> spawnPoints = new List<Transform>(); // Spawn points

    [SerializeField] private float secondsBetweenSpawn;
    private float secondsSinceLastSpawn;
    
    void Start()
    {
        secondsSinceLastSpawn = 0;
        foreach (Transform child in transform)
        {
            spawnPoints.Add(child);
        }
    }

    private void FixedUpdate()
    {
        if (isActive)
        {
            secondsSinceLastSpawn += Time.deltaTime;
            if (secondsSinceLastSpawn >= secondsBetweenSpawn)
            {
                secondsSinceLastSpawn = 0;
                Spawn();
            }
        }
    }

    void Spawn()
    {
        for (int i = 0; i < spawnPoints.Count; i++)
        {
            Instantiate(prefab, spawnPoints[i].position, transform.rotation);
        }
    }
}
