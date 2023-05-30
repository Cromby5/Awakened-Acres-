using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[System.Serializable]
public class Inventory : IItemContainer
{
    [System.Serializable]
    public class Slot
    {
        public ItemData item;
        public ItemType type;
        public int count;
        public int maxAllowed;

        public Sprite icon;

        public Slot()
        {
            type = ItemType.NONE;
            item = null;
            count = 0;
            maxAllowed = 99;
        }

        public bool CanAddItem()
        {
            if(count < maxAllowed)
            {
                return true;
            }
            else
            {
                return false;
            }
        }

        public void AddItem(ItemData item)
        {
            this.item = item;
            this.type = item.type;
            this.icon = item.itemIcon;
            count++;

        }

        public void RemoveItem()
        {
            if (count > 0)
            {
                count--;

                if( count == 0)
                {
                    icon = null;
                    item = null;
                    type = ItemType.NONE;
                }
            }
        }
        public void DeleteItem()
        {
            count = 0;
            icon = null;
            item = null;
            type = ItemType.NONE;
        }
    }
 

    public List<Slot> slots = new List<Slot>();

    public Inventory(int numSlots)
    {
        for (int i = 0; i < numSlots; i++)
        {
            Slot slot = new Slot();
            slots.Add(slot);
        }
    }

    public void Add(ItemData item)
    {
        foreach (Slot slot in slots)
        {
            if (slot.item == item && slot.CanAddItem())
            {
                slot.AddItem(item);
                Debug.Log("Added " + item.itemName + " to slot " + slots.IndexOf(slot));
                return;
            }
        }

        foreach(Slot slot in slots)
        {
            if (slot.type == ItemType.NONE)
            {
                slot.AddItem(item);
                return;
            }
        }
    }

    public void Remove(int index)
    {
        slots[index].RemoveItem();
    }

    public void Equip()
    {
        
    }
    public void Delete(int index)
    {
        slots[index].DeleteItem();
    }
    // IItemContainer stuff, Sorry for the mess, easier to do this than to try and make it work with the above for now
    public bool ContainsItem(ItemData item)
    {
        for (int i = 0; i < slots.Count; i++) // HERE
        {
            if (slots[i].item == item)
            {
                return true;
            }
        }
        return false;
    }
    public int CountItem(ItemData item)
    {
        int num = 0;
        
        for (int i = 0; i < slots.Count; i++) // HERE
        {
            if (slots[i].item == item)
            {
                num += slots[i].count;
                //num++;
            }
        }
        Debug.Log(num);
        return num;
    }
    public bool AddItem(ItemData item)
    {
        for (int i = 0; i < slots.Count; i++) // HERE
        {
            if (slots[i].item == null)
            {
                Add(item);
                return true;
            }
        }
        return false;
    }
    
    public bool RemoveItem(ItemData item)
    {
        for (int i = 0; i < slots.Count; i++) // HERE
        {
            if (slots[i].item == item)
            {
                Remove(i);
                return true;
            }
        }
        return false;
    }
    public bool IsFull()
    {
        for (int i = 0; i < slots.Count; i++) // HERE
        {
            if (slots[i].item == null)
            {
                return false;
            }
        }
        return true;
    }

}
