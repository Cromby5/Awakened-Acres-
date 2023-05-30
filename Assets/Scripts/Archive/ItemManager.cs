using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ItemManager : MonoBehaviour
{
    /*
    public Collectable[] collectableItems;

    private Dictionary<ItemData, ItemType> collectableItemsDict = new Dictionary<ItemData, ItemType>();

    private void Awake()
    {
        foreach(Collectable item in collectableItems)
        {
            AddItem(item);
        }
    }

    private void AddItem(Collectable item)
    {
        if(!collectableItemsDict.ContainsKey(item.type))
        {
            collectableItemsDict.Add(item.type, item);
        }
    }
    
    public ItemData GetItemByType(ItemData type)
    {
        if(collectableItemsDict.ContainsKey(type))
        {
            return collectableItemsDict[type];
        }

        return null;
    }
    */
}
