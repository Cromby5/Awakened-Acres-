using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class KeyDoor : MonoBehaviour
{
    [SerializeField] private int keysToOpen;

    [SerializeField] private GameObject extrasToOpen;

    [SerializeField] private GameObject extrasToClose;

    [SerializeField] private TextAsset inkJSON;


   [SerializeField] private Animator anim;


    private void OnTriggerEnter(Collider other)
    {
        if (other.gameObject.CompareTag("Player"))
        {
            bool i = other.gameObject.GetComponent<Player>().CheckKey(keysToOpen);
            if (i)
            {
                if (inkJSON != null)
                {
                    InkDialogueManager.GetDialogueManager().StartDialogue(inkJSON);
                }

                if (extrasToOpen != null)
                {
                    Destroy(extrasToOpen);
                }
                if (extrasToClose != null)
                {
                    extrasToClose.SetActive(true);
                }
                
                if (anim != null)
                {
                    anim.SetBool("isOpen", true);
                }
                else
                {
                    Destroy(gameObject);
                }
            }
        }
    }
}
