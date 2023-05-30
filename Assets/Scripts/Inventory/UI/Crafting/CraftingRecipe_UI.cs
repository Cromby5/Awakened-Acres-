using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CraftingRecipe_UI : MonoBehaviour
{
    [SerializeField] RectTransform arrowParent;
    
    public Inventory_UI itemContainer;

    //public CraftingData craftingData;
    
    public List<Slots_UI> slots = new();
    
    private CraftingData craftingData;
    public CraftingData CraftingRecipe
    {
       get { return craftingData; }
       set { SetCraftingRecipe(value); }
    }
    
    // Start is called before the first frame update
    void Start()
    {
        
    }
    
    // Update is called once per frame
    void Update()
    {

    }
    public void OnCraftingButtonClick()
    {
        if (craftingData != null && itemContainer != null)
        {
            if (craftingData.CanCraft(itemContainer.player.inventory))
            {
                if (!itemContainer.player.inventory.IsFull())
                {
                    Debug.Log("Craft Enter");
                    craftingData.Craft(itemContainer.player.inventory);
                }
                else
                {
                    Debug.Log("Inventory is full");
                }
            }
            else
            {
                Debug.Log("Not enough resources");
            }
        }
        else
        {
            Debug.Log("CraftingData or The Item Container is null");
        }
    }
    
    private void SetCraftingRecipe(CraftingData newCraftingRecipe)
    {
        craftingData = newCraftingRecipe;
        
        if (craftingData != null)
        {
            int slotIndex = 0;
            slotIndex = SetSlots(craftingData.items, slotIndex);
            arrowParent.SetSiblingIndex(slotIndex);
            slotIndex = SetSlots(craftingData.resultItem, slotIndex);
            
            for (int i = slotIndex; i < slots.Count; i++)
            {
                slots[i].transform.parent.gameObject.SetActive(false);
            }
            
            gameObject.SetActive(true);
        }
        else
        {
            gameObject.SetActive(false);
        }
    }
    
    private int SetSlots(IList<ItemAmount> itemAmountList, int slotIndex)
    {
        for (int i = 0; i < itemAmountList.Count; i++, slotIndex++)
        {
            ItemAmount itemAmount = itemAmountList[i];
            Slots_UI itemSlot = slots[slotIndex];

            itemSlot.itemIcon.sprite = itemAmount.item.itemIcon;
            itemSlot.quantityText.text = itemAmount.amount.ToString();
            itemSlot.transform.parent.gameObject.SetActive(true);
        }
        return slotIndex;
    }
    
}
