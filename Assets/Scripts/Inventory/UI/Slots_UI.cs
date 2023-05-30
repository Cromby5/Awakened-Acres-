using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using TMPro;

public class Slots_UI : MonoBehaviour
{
    public Image itemIcon;
    public TextMeshProUGUI quantityText;
    public TextMeshProUGUI itemNameText;

    public GameObject highlight;

    public void SetItem(Inventory.Slot slot)
    {
        if (slot != null)
        {
            itemIcon.sprite = slot.icon;
            itemIcon.color = new Color(1, 1, 1, 1);
            quantityText.text = slot.count.ToString();
            itemNameText.text = slot.item.itemName;
        }
    }

    public void SetEmpty()
    {
        itemIcon.sprite = null;
        itemIcon.color = new Color(1, 1, 1, 0);
        quantityText.text = "";
        itemNameText.text = "";
    }

    public void SetHighlight()
    {
        if (highlight.activeSelf)
        {
            highlight.SetActive(false);
        }
        else
        {
            highlight.SetActive(true);
        }
    }
}
