using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

// Trying to put a similar system to below in (reworked for this inventory)
// https://www.youtube.com/watch?v=gZsJ_rG5hdo
// Sounds good in my head with the way I want it to work.
// Means you could have recipes that reference other data to get our result data

[Serializable]
public struct ItemAmount
{
    public ItemData item;
    [Range(1,99)]
    public int amount;
}
    
[CreateAssetMenu(fileName = "CraftingData", menuName = "Data/CraftingData", order = 3)]
public class CraftingData : ScriptableObject
{
    public List<ItemAmount> items; // The items required to create the result
    public List<ItemAmount> resultItem; // The item that will be given to the player

    public ItemAmount ItemAmount
    {
        get => default;
        set
        {
        }
    }

    public bool CanCraft(IItemContainer itemContainer)
    {
        // Check if the player has the required items to craft the result item
        foreach (ItemAmount itemAmount in items)
        {
             if (itemContainer.CountItem(itemAmount.item) < itemAmount.amount)
             {
                 return false;
             }
         }
         return true;
     }

    public void Craft(IItemContainer itemContainer)
    {
        if (CanCraft(itemContainer))
        {
            Debug.Log("Can Craft 2");
            foreach (ItemAmount itemAmount in items)
            {
                for (int i = 0; i < itemAmount.amount; i++)
                {
                    Debug.Log("Removing Item");
                    itemContainer.RemoveItem(itemAmount.item);
                }
            }

            foreach (ItemAmount itemAmount in resultItem)
            {
                for (int i = 0; i < itemAmount.amount; i++)
                {
                    Debug.Log("Adding Item");
                    itemContainer.AddItem(itemAmount.item);
                }
            }
        }
    }
     
    
}
