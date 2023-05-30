using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class DialogueTrigger : MonoBehaviour
{
    public Dialogue dialogue;

    public bool force;

    public bool played = false;
    private void Start()
    {
        if (force && !played)
        {
            TriggerDialogue();
        }
    }
    
    public void TriggerDialogue()
    {
        if (!played)
        {
            GameManager.DialogueManager.StartDialogue(dialogue);
            played = true;
        }
    }

    private void OnTriggerEnter(Collider other)
    {
        if (other.gameObject.CompareTag("Player") && !played)
        {
            TriggerDialogue();
        }
    }

}
