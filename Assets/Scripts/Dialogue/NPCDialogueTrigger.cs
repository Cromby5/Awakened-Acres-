using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class NPCDialogueTrigger : SelectBase
{
    public Dialogue[] dialogue;
    private NPCMove npcMove;

    void Start()
    {
        npcMove = GetComponent<NPCMove>();
    }

    public override void Interact()
    {
        // Trigger dialogue
        int i = Random.Range(0, dialogue.Length);
        npcMove.SetState(2);
        GameManager.DialogueManager.StartDialogue(dialogue[i],npcMove);
    }
}
