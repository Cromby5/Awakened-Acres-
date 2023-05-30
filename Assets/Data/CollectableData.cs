using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[CreateAssetMenu(fileName = "CollectableData", menuName = "Data/CollectableData", order = 2)]
public class CollectableData : ItemData
{
    public int amount; // Amount to increase the players mana/ability bar by

    public void Awake()
    {
        type = ItemType.Collectables;
    }
}
