using System.Collections;
using System.Collections.Generic;
using Unity.VisualScripting;
using UnityEngine;

public class Player : MonoBehaviour, IDataPersist
{
    public Inventory inventory;

    public Inventory equipinventory;

    [SerializeField] private PlayerInteraction playerInteraction;
    [SerializeField] private HealthSystem healthSystem;


    [SerializeField] private Transform itemPlace;

    // These are for putting these items on the player on load
    [SerializeField] private ItemData carrotSeeds;

    [SerializeField] private LayerMask groundLayer;

    private int keyCount = 0;

    [SerializeField] private DrawKeysHeld keyUI;

    public void Awake()
    {
        // Done in GameData now,
        inventory = new Inventory(10);
        equipinventory = new Inventory(1);
   
    }

    void Start()
    {
        for (int i = 0; i < 20; i++)
        {
            inventory.AddItem(carrotSeeds);
        }
    }

    public void LoadData(GameData data)
    {
        transform.position = data.playerTransformPos;
        inventory = data.inventory;
        playerInteraction.SwitchSpell(data.selectedSpell);
    }

    public void SaveData(GameData data)
    {
        data.playerTransformPos = transform.position;
        data.inventory = inventory;
        data.selectedSpell = playerInteraction.GetSelectedTool();
    }
    private void Update()
    {
    /*
        if(Input.GetKeyDown(KeyCode.Space))
        {
            Vector3Int position = new Vector3Int((int)transform.position.x, (int)transform.position.y, 0);

            if (GameManager.instance.tileManager.IsInteractable(position))
            {
                Debug.Log("Tile is interactable");
                GameManager.instance.tileManager.SetInteracted(position);
            }
        }
    */
    }
        
    public void DropItem(ItemData item)
    {
        if (item.itemPrefab != null)
        {
            GameObject droppedItem = Instantiate(item.itemPrefab, transform.position + Vector3.forward, Quaternion.identity);
        }
        //droppedItem.GetComponent<Rigidbody>().AddForce(transform.forward, ForceMode.Impulse);
    }

    public bool UseItem(ItemData item)
    {
        // Change so each inv item has types potion, seeds, placeable items (trees,chairs)
        switch (item.itemName)
        {
            case "Potion":
                Debug.Log("Potion used");
                GameManager.AudioManager.Play("Potion");
                //playerInteraction.AbilityBarIncrease(50);
                playerInteraction.abilityBar.AbilityBarIncrease(50);
                return true;
            case "Super Potion":
                GameManager.AudioManager.Play("Potion");
                playerInteraction.abilityBar.AbilityBarIncrease(100);
                return true;
            case "Health Potion":
                Debug.Log("Health Potion used");
                GameManager.AudioManager.Play("Potion");
                healthSystem.Heal(2);
                return true;
            case "CarrotSeed":
                Debug.Log("Carrot Seed used");
                // place Carrot Seed
                if (playerInteraction.selectedLand != null)
                {
                    bool t = playerInteraction.selectedLand.InvInteract("CarrotSeed");
                    return t;
                }
                return false;
            case "ChilliSeed":
                Debug.Log("Chilli Seed used");
                // place Chilli Seed
                if (playerInteraction.selectedLand != null)
                {
                    bool e = playerInteraction.selectedLand.InvInteract("ChilliSeed");
                    return e;
                }
            return false;
            case "CherrySeed":
                Debug.Log("Cherry Seed used");
                // place Chilli Seed
                if (playerInteraction.selectedLand != null)
                {
                    bool e = playerInteraction.selectedLand.InvInteract("CherrySeed");
                    return e;
                }
            return false;
            case "TreeSeed":
                Debug.Log("Tree Seed used");
                // place Tree Seed
                if (playerInteraction.selectedLand == null && !Physics.CheckSphere(itemPlace.position + new Vector3(0f,0.6f,0f), 0.5f, groundLayer))
                {
                    Instantiate(item.itemPrefab, itemPlace.position, Quaternion.identity);
                    return true;
                }
                return false;
            default:
                Debug.Log("Item not found but not used");
                return false;
        }
    }

    public void AddKey()
    {
        Debug.Log("Key added");
        keyCount++;
        keyUI.DrawKeys();
        keyUI.UpdateKey(keyCount);
    }
    public bool CheckKey(int keysToOpen)
    {
        Debug.Log("Key attempt");
        if (keyCount >= keysToOpen)
        {
            keyCount = 0;
            keyUI.ClearKeys();
            return true;
        }
        else
        {
            return false;
        }
    }

    public void EquipItem(ItemData item)
    {
        
    }
}
