using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class DialogueReferences : MonoBehaviour
{
    public InkDialogueTrigger[] dialogueTrigger;

    public void Awake()
    {
        GameManager.dialogueReferences = this;
    }
}
