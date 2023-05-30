using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class InkDialogueTrigger : MonoBehaviour
{

    [SerializeField] private TextAsset inkJSON;

    public bool force;

    public bool played = false;

    void Start()
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
            InkDialogueManager.GetDialogueManager().StartDialogue(inkJSON);
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
