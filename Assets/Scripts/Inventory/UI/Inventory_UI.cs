using System.Collections;
using System.Collections.Generic;
using System.Linq;
using UnityEngine;

public class Inventory_UI : MonoBehaviour
{
    public GameObject InventoryPanel;

    public Player player;

    public List<Slots_UI> slots = new List<Slots_UI>();
    
    public Slots_UI equippedSlot;

    public int selectedSlot = -1;
    
    public void ToggleInventory()
    {
        if (InventoryPanel != null)
        {
            if (!InventoryPanel.activeSelf)
            {
                InventoryPanel.SetActive(true);
                Refresh();
            }
            else
            {
                InventoryPanel.SetActive(false);
            }
        }
    }
    private void Update()
    {
        // Losing hope doing the inv bar so doing this for now, its bad please remove in ip3
        Refresh();
    }
    void Refresh()
    {
        if(slots.Count == player.inventory.slots.Count)
        {
            for (int i = 0; i < slots.Count; i++)
            {
                if(player.inventory.slots[i].type != ItemType.NONE)
                {
                    slots[i].SetItem(player.inventory.slots[i]);
                }
                else
                {
                    slots[i].SetEmpty();
                }
            }
        }
    }

    public void Remove(int slot)
    {
        ItemData itemToDrop = player.inventory.slots[slot].item;
        if (itemToDrop != null)
        {
            player.DropItem(itemToDrop);
            player.inventory.Remove(slot);
            Refresh();
        }
    }

    public void Use(int slot)
    {
        if (!GameManager.player.canInput)
            return;
        
        ItemData itemToUse = player.inventory.slots[slot].item;
        if (itemToUse != null)
        {
            bool isUsed = player.UseItem(itemToUse);
            if (isUsed)
            {
                player.inventory.Remove(slot);
                Refresh();
            }
        }
    }

    public void UseEquip()
    {
        ItemData itemToUse = player.equipinventory.slots[0].item;
        if (itemToUse != null)
        {
            player.UseItem(itemToUse);
            player.equipinventory.Remove(0);
            if (player.equipinventory.slots[0].type != ItemType.NONE)
            {
                equippedSlot.SetItem(player.equipinventory.slots[0]);
            }
            else
            {
                equippedSlot.SetEmpty();
            }
        }
    }
    
    public void Equip(int slot)
    {
        ItemData itemToEquip = player.inventory.slots[slot].item;
        int amountOfItems = player.inventory.slots[slot].count;

        if (itemToEquip != null)
        {
            if (player.equipinventory.IsFull()) // Is our equip slot full?
            {
                ItemData itemToStore = player.equipinventory.slots[0].item; // Temp store the item
                int temp = player.equipinventory.slots[0].count; // Temp store the amount
                player.equipinventory.Delete(0); // Delete it from the equip inv
                // Keep adding the item to match the temp amount
                for (int i = 0; i < temp; i++)
                {
                    player.inventory.Add(itemToStore);
                }
            }
            equippedSlot.SetItem(player.inventory.slots[slot]); // Set the icons on the equip slot
            player.equipinventory.Add(itemToEquip);
            player.equipinventory.slots[0].count = amountOfItems;
            player.inventory.Delete(slot);
            equippedSlot.transform.position = slots[slot].transform.position;
            Refresh();
        }
    }
    public void ChangeEquip()
    {
        if (GameManager.LevelManager.isPaused == false)
        {
            if (selectedSlot >= 9)
            {
                selectedSlot = 0;
                slots[selectedSlot].SetHighlight();
                slots[9].SetHighlight();
            }
            else
            {
                selectedSlot++;
                slots[selectedSlot].SetHighlight();
                slots[selectedSlot - 1].SetHighlight();

            }

            if (player.inventory.slots[selectedSlot].type != ItemType.NONE)
            {
                //Equip(selectedSlot);
            }
        }
        else if (GameManager.je != null)
        {
            GameManager.je.NextPage();
            
        }
    }
    public void ChangeEquipInverse()
    {
        if (GameManager.LevelManager.isPaused == false)
        {
            if (selectedSlot <= 0)
            {
                selectedSlot = 9;
                slots[selectedSlot].SetHighlight();
                slots[0].SetHighlight();
            }
            else
            {
                selectedSlot--;
                slots[selectedSlot].SetHighlight();
                slots[selectedSlot + 1].SetHighlight();
            }

            if (player.inventory.slots[selectedSlot].type != ItemType.NONE)
            {
                //Equip(selectedSlot);
            }
        }
        else if (GameManager.je != null)
        {
            GameManager.je.PreviousPage();
        }
    }
}
