using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Bomb : MonoBehaviour
{
    public float explodeTime = 4f; // Time for the bomb to explode

    private float count; // Timer until explode time

    private bool hasExploded = false; // Keeping track if this bomb has exploded or not

    public GameObject explosionPrefab;

    void Start()
    {
        count = explodeTime; // Counter starts at the explodetime
    }

    void Update()
    {
        count -= Time.deltaTime; // Counts down
        // When we hit 0 or under explode
        if (count <= 0 && !hasExploded)
        {
            Explode();
        }
    }
    void Explode()
    {
        GameManager.AudioManager.Play("Explode"); // Plays the bomb explode sound
        hasExploded = true;
        Instantiate(explosionPrefab, transform.position, transform.rotation); // Spawn explosion
        explosionPrefab.transform.localScale = Vector3.zero; // Starts the explosion scale at 0 as it will expand out
        Destroy(gameObject); // Destroys the grenade
    }
}
