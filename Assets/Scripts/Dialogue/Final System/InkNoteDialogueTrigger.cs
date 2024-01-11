using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class InkNoteDialogueTrigger : SelectBase
{
    
    public TextAsset[] inkJSON; // Dialogues
    
    // Start is called before the first frame update
    void Start()
    {
        
    }
    
    public override void Interact()
    {
        
            int i = Random.Range(0, inkJSON.Length);
            
            InkDialogueManager.GetDialogueManager().StartDialogue(inkJSON[i]);
        
    }
}
