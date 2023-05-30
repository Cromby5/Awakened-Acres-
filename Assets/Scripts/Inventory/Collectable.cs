using System.Collections;
using System.Collections.Generic;
using System.Linq;
using Unity.VisualScripting.Antlr3.Runtime;
using UnityEngine;

public class Collectable : MonoBehaviour, IDataPersist
{
    //public CollectableType type;
    public CollectableData[] data;

    public Rigidbody rigidBody;

    [SerializeField] private string id;

    [SerializeField] private bool canCollect = true;

    [SerializeField] private int dialogueRef;

    [ContextMenu("Generate guid for id")]
    private void GenerateGuid()
    {
        id = System.Guid.NewGuid().ToString();
    }

    public void LoadData(GameData data)
    {
     

    }
    public void SaveData(GameData data)
    {
        
    }


    private void Awake()
    {
        rigidBody = GetComponent<Rigidbody>();
    }
    private void FixedUpdate()
    {
        //rotate object
        if (canCollect)
        transform.Rotate(0, 1, 0);
    }
    private void OnTriggerEnter(Collider collision)
    {
        Player player = collision.GetComponent<Player>();
        
        if (player != null && canCollect)
        {
            GameManager.AudioManager.Play("Item Collected");
            GameManager.dialogueReferences.dialogueTrigger[dialogueRef].TriggerDialogue();
            foreach (var data in data)
            {
                player.inventory.Add(data);
                collision.GetComponent<AbilityBar>().AbilityBarIncrease(data.amount);
            }
            //collision.GetComponentInChildren<PlayerInteraction>().AbilityBarIncrease(data.amount);
            Destroy(gameObject);
        }
    }

    public void SetCollect(bool t)
    {
        canCollect = t;
    }
}
    

/*
public enum CollectableType
{
    NONE, CARROT_SEED
}
*/