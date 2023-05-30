using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class InkNPCDialogueTrigger : SelectBase
{
    
    public TextAsset[] inkJSON; // Dialogues
    private NPCMove npcMove;
    
    // Start is called before the first frame update
    void Start()
    {
        npcMove = GetComponent<NPCMove>();
    }
    
    public override void Interact()
    {
        if (npcMove.GetState() != 3)
        {
            // Trigger dialogue
            int i = Random.Range(0, inkJSON.Length);
            npcMove.SetState(2);
            InkDialogueManager.GetDialogueManager().StartDialogue(inkJSON[i], npcMove);
        }
        else
        {
            npcMove.SetState(2);
            InkDialogueManager.GetDialogueManager().StartDialogue(npcMove.GetDialogue(), npcMove);
        }

    }
}
