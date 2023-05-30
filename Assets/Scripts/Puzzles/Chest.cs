using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Chest : MonoBehaviour, IDataPersist
{
    [SerializeField] private string id;
    
    public bool triggerOpen = true;
    
    [ContextMenu("Set Guid")]
    public void SetGuid()
    {
        id = System.Guid.NewGuid().ToString();
    }

    public GameObject item;
    public Transform spawn;

    public Animator animator;
    public float spawnWaitTime = 1f;


    bool isOpen = false;
    public void OpenChest()
    {
        if (isOpen)
            return;
        
        isOpen = true;
        GameManager.AudioManager.Play("Chest Open");
        StartCoroutine(Wait());
        animator.SetBool("isOpen", true);
    }

    public void LoadData(GameData data)
    {
        Debug.Log("Loading chest data");
        data.collectedObjects.TryGetValue(id, out isOpen);
        if (isOpen)
        {
            //animator.SetBool("isOpen", true);
            isOpen = true;
        }
    }

    public void SaveData(GameData data)
    {
        Debug.Log("Saving chest data");
        if (data.collectedObjects.ContainsKey(id))
        {
            data.collectedObjects.Remove(id);
        }
        data.collectedObjects.Add(id, isOpen);
    }

    private void OnTriggerEnter(Collider other)
    {
        if (other.gameObject.CompareTag("Player") && !isOpen && triggerOpen)
        {
            OpenChest();
        }
    }

    IEnumerator Wait()
    {
        yield return new WaitForSeconds(spawnWaitTime);
        Instantiate(item, spawn.position, Quaternion.identity);
        yield break;
    }
}
