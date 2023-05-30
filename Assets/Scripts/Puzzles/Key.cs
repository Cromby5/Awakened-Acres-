using System.Collections;
using System.Collections.Generic;
using Unity.VisualScripting.Antlr3.Runtime;
using UnityEngine;
 
public class Key : MonoBehaviour, IDataPersist
{
    [SerializeField] private string id;
    [ContextMenu("Set Guid")]
    public void SetGuid()
    {
        id = System.Guid.NewGuid().ToString();
    }
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        
    }

    private void OnTriggerEnter(Collider other)
    {
        if (other.gameObject.tag == "Player")
        {
            other.gameObject.GetComponent<Player>().AddKey();
            Destroy(gameObject);
        }
    }

    public void LoadData(GameData data)
    {
      // look at chest
    }

    public void SaveData(GameData data)
    {
    
    }
}
