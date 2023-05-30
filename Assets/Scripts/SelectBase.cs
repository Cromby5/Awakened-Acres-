using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SelectBase : MonoBehaviour
{
    public GameObject select;

   [SerializeField] private protected Material defaultMat;
   [SerializeField] private protected Material selectMat;
    
   [SerializeField] private bool canSelect = true;


    // Start is called before the first frame update
    void Start()
    {
        //Deselect the resource by default
        Select(false);
    }

    // Update is called once per frame
    void Update()
    {
        
    }

    public virtual void Interact()
    {
        
    }
    public void Select(bool toggle)
    {
        // Toggle selection square
        select.SetActive(toggle);
    }
    
    private void OnTriggerEnter(Collider collision)
    {
        PlayerInteraction player = collision.GetComponentInChildren<PlayerInteraction>();
        if (player != null && canSelect)
        {
            select.SetActive(true);
            player.otherSelect = this;
        }
    }

    private void OnTriggerExit(Collider collision)
    {
        PlayerInteraction player = collision.GetComponentInChildren<PlayerInteraction>();
        if (player != null && canSelect)
        {
            player.otherSelect = null;
            select.SetActive(false);
        }
    }
    
}
