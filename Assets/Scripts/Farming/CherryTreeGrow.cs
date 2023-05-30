using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CherryTreeGrow : SelectBase
{

    [SerializeField] private Transform[] spawnPoints;
    [SerializeField] private GameObject cherryPrefab;
    private int currentIndex;
    [SerializeField] private float growTime = 15f;

    // Start is called before the first frame update
    void Start()
    {
        currentIndex = 0;
        StartCoroutine(SpawnCherry());
    }

    // Update is called once per frame
    void Update()
    {
        
    }

    IEnumerator SpawnCherry()
    {
        yield return new WaitForSeconds(growTime);
        // Spawn Cherry
        if (spawnPoints[currentIndex].transform.childCount == 0)
        {
            Instantiate(cherryPrefab, spawnPoints[currentIndex].position, spawnPoints[currentIndex].rotation, spawnPoints[currentIndex].transform);
        }
        
        if (currentIndex == spawnPoints.Length - 1)
        {
            currentIndex = 0;
        }
        else
        {
            currentIndex++;
        }
        StartCoroutine(SpawnCherry());
    }

    public override void Interact()
    {
        foreach (var spawnPoint in spawnPoints)
        {
            if (spawnPoint.transform.childCount > 0)
            {
                spawnPoint.GetComponentInChildren<Rigidbody>().useGravity = true;
                spawnPoint.GetComponentInChildren<Collectable>().SetCollect(true);
            }
        }
    }
    
}
