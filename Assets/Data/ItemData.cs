using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public enum ItemType
{
    NONE,
    Collectables,
    Spell,
    Tool,
}


[CreateAssetMenu(fileName = "ItemData", menuName = "Data/ItemData", order = 0)]
public class ItemData : ScriptableObject
{
    public GameObject itemPrefab; // Item that can be dropped
    public ItemType type;
    public string itemName;
    [TextArea(3,5)]
    public string itemDescription;
    public Sprite itemIcon;
}
