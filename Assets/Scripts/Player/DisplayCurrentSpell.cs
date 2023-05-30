using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class DisplayCurrentSpell : MonoBehaviour
{
    
    [SerializeField] private Sprite[] spellImages;
    [SerializeField] private GameObject[] spellBlockers;

    private Image image;
    
    void Start()
    {
        image = GetComponent<Image>();
        for (int i = 0; i < spellBlockers.Length; i++)
        {
            if (GameManager.playerInteract.unlocks[i + 1])
            {
                spellBlockers[i].SetActive(false);
            }
            else
            {
                spellBlockers[i].SetActive(true);
            }
        }
    }
    public void ChangeImage(int index)
    {
        image.sprite = spellImages[index];
    }

    public void UnHideSpell(int index)
    {
        spellBlockers[index].SetActive(false);
    }
}
