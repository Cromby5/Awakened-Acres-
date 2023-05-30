using System.Collections;
using System.Collections.Generic;
using Unity.VisualScripting;
using UnityEngine;
using UnityEngine.EventSystems;

public class CraftingOnMouseOver : MonoBehaviour, IPointerEnterHandler, IPointerExitHandler
{
    public List<GameObject> items = new List<GameObject>();

    private void Start()
    {
        for (int i = 0; i < items.Count; i++)
        {
            items[i].SetActive(false);
        }
    }
    public void OnPointerEnter(PointerEventData eventData)
    {
        for (int i = 0; i < items.Count; i++)
        {
            items[i].SetActive(true);
        }
    }

    public void OnPointerExit(PointerEventData eventData)
    {
        for (int i = 0; i < items.Count; i++)
        {
            items[i].SetActive(false);
        }
    }
  
}
