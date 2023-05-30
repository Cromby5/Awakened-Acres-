using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Cauldron : MonoBehaviour
{
    // Destroying this provides the player with new skills as they free the seeds to be planted
    // 0: Onion, 1: N/A Farming, 2: Light, 3: Fire 4: Bomb
    private enum SpellUnlocks 
    {
        Onion,
        Farming,
        Light,
        Fire,
        Bomb
    }
    
    [SerializeField] private SpellUnlocks spellUnlock;
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        
    }

    private void OnTriggerEnter(Collider other)
    {
        if (other.CompareTag("Player"))
        {
            Destroy(gameObject);
        }
    }
    private void OnDestroy()
    {
        GameManager.playerInteract.Unlock((int)spellUnlock);
    }
}
