using Newtonsoft.Json;
using System;
using System.Collections;
using System.Collections.Generic;
using System.IO;
using TMPro;
using UnityEngine;
using UnityEngine.UI;

public class DialogueManager : MonoBehaviour
{
    [Header("Dialogue UI")]
    public TextMeshProUGUI nameText;
    public TextMeshProUGUI dialogueText;
    public Image speakerImage;
    public Animator animator;

    public Button next;
    
    private Queue<string> sentences;

    private NPCMove npcMove;
    
    private bool canSelect = false;
    
    private void Awake()
    {
        GameManager.DialogueManager = this;
        sentences = new Queue<string>();
        next.Select();
    }
    void Start()
    {
      
    }

    void Update()
    {
        if (GameManager.input.currentControlScheme != "Keyboard&Mouse" && canSelect)
        {
            next.Select();
        } 
    }
    
    public void StartDialogue(Dialogue dialogue)
    {
        // disable control
        if (GameManager.LevelManager != null)
        {
            GameManager.LevelManager.isPaused = true;
            GameManager.player.MoveState(false, false);
        }
        animator.gameObject.SetActive(true);
        speakerImage.gameObject.SetActive(true);
        animator.SetBool("IsOpen", true);
        //next.Select();
        //dialogue.ReadFile();
        Debug.Log("Starting conversation with " + dialogue.speakerName);
        nameText.text = dialogue.speakerName;
        sentences.Clear();
        foreach (string sentence in dialogue.sentences)
        {
            sentences.Enqueue(sentence);
        }
        DisplayNextSentence();
    }
    
    public void StartDialogue(Dialogue dialogue, NPCMove m)
    {
        npcMove = m;
        StartDialogue(dialogue);
    }
    
    public void DisplayNextSentence()
    {
        if (sentences.Count == 0)
        {
            EndDialogue();
            return;
        }
        string sentence = sentences.Dequeue();
        StopAllCoroutines();
        StartCoroutine(TypeSentence(sentence));
    }

    IEnumerator TypeSentence(string sentence)
    {
        dialogueText.text = sentence;
        dialogueText.maxVisibleCharacters = 0;

        bool isTag = false; // For text tags such as colour, bold etc
        
        foreach (char letter in sentence.ToCharArray())
        {
            if (letter == '<' || isTag) // This prevents tags showing up briefly in text before applying
            {
                isTag = true;
                if (letter == '>')
                {
                    isTag = false;
                }
            }
            else
            {
                dialogueText.maxVisibleCharacters++;
                yield return null;
            }
        }
    }

    void EndDialogue()
    {
        canSelect = false;
        speakerImage.gameObject.SetActive(false);
        animator.SetBool("IsOpen", false);
        Debug.Log("End of conversation.");
        // reneable control
        GameManager.LevelManager.isPaused = false;
        GameManager.player.MoveState(true, true);
        if (npcMove != null)
        {
            npcMove.SetState(0);
            npcMove = null;
        }
        //animator.gameObject.SetActive(false);
      
    }

    void OnControlsChanged()
    {
        next.Select();
    }
}
