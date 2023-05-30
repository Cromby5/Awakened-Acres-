using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class HealthBar : MonoBehaviour
{
    [SerializeField] private GameObject heartPrefab;

    private List<HealthHeart> hearts = new List<HealthHeart>();

    public void DrawHealth(int Health, int maxHealth)
    {
        ClearHearts();
        // This takes half hearts into account
        float maxHealthRemainder = maxHealth % 2;
        int heartsToMake = (int)((maxHealth / 2) + maxHealthRemainder);
        for (int i = 0; i < heartsToMake; i++)
        {
            CreateEmptyHeart();
        }

        for (int i = 0; i < hearts.Count; i++)
        {
            int heartStatusRemainder = Mathf.Clamp((Health - (i * 2)), 0, 2);
            hearts[i].SetHeart((HeartState)heartStatusRemainder);
        }
    }

    void CreateEmptyHeart()
    {
        GameObject heart = Instantiate(heartPrefab, transform);
        HealthHeart hh = heart.GetComponent<HealthHeart>();
        hh.SetHeart(HeartState.Empty);
        hearts.Add(hh);
    }
    
    public void ClearHearts()
    {
        foreach (Transform heart in transform)
        {
            Destroy(heart.gameObject);
        }
        hearts.Clear();
    }
}
