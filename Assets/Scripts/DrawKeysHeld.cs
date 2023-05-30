using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class DrawKeysHeld : MonoBehaviour
{

    [SerializeField] private GameObject keyPrefab;

    private List<HealthHeart> keys = new List<HealthHeart>(); // Reuse since i can get away with it

    public void DrawKeys()
    {
        if (keys.Count > 0) return;
        for (int i = 0; i < 2; i++)
        {
            GameObject key = Instantiate(keyPrefab, transform);
            HealthHeart keyt = key.GetComponent<HealthHeart>();
            keyt.SetHeart(HeartState.Empty);
            keys.Add(keyt);
        }
    }

    public void UpdateKey(int keysHeld)
    {
        for (int i = 0; i < keysHeld; i++)
        {
            keys[i].SetHeart(HeartState.Full);
        }
    }

    public void ClearKeys()
    {
        foreach (Transform k in transform)
        {
            Destroy(k.gameObject);
        }
        keys.Clear();
    }
}
