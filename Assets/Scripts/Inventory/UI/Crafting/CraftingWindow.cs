using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CraftingWindow : MonoBehaviour
{
    [SerializeField] CraftingRecipe_UI recipeUIPrefab;
    [SerializeField] RectTransform recipeUIParent;
    [SerializeField] List<CraftingRecipe_UI> recipeUIs;

    public Inventory_UI ItemContainer;
    public List<CraftingData> CraftingRecipes;

    
    private void OnValidate()
    {
        Init();
    }
    private void Start()
    {
        Init();
    }

    private void Init()
    {
        recipeUIParent.GetComponentsInChildren<CraftingRecipe_UI>(includeInactive: true, result: recipeUIs);
        UpdateCraftingRecipes();
    }
    
    public void UpdateCraftingRecipes()
    {
        for (int i = 0; i < CraftingRecipes.Count; i++)
        {
            if (recipeUIs.Count == i)
            {
                recipeUIs.Add(Instantiate(recipeUIPrefab, recipeUIParent, false));
            }
            else if (recipeUIs[i] == null)
            {
                recipeUIs[i] = Instantiate(recipeUIPrefab, recipeUIParent, false);
            }

            recipeUIs[i].itemContainer = ItemContainer;
            recipeUIs[i].CraftingRecipe = CraftingRecipes[i];
        }

        for (int i = CraftingRecipes.Count; i < recipeUIs.Count; i++)
        {
            recipeUIs[i].CraftingRecipe = null;
        }
    }

}
