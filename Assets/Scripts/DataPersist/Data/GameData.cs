using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[System.Serializable]
public class GameData
{
    // Misc
    public int level;
    // Player
    public Vector3 playerTransformPos;
    public int currentHealth;
    public int maxHealth;
    public Inventory inventory;
    public int selectedSpell;
    // Level
    public SerializableDictionary<string, bool> collectedObjects;

    // Default constructor, no save to load
    public GameData()
    {
        level = 1;
        selectedSpell = 0;
        
        playerTransformPos = new Vector3(-5.56f, 1.39f, -5.83f);
        inventory = new Inventory(10);

        collectedObjects = new SerializableDictionary<string, bool>();
    }
    
}
