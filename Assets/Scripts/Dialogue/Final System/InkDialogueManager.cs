using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using TMPro;
using Ink.Runtime;
using UnityEngine.UI;

// This is the new manager utilising the ink dialogue system to provide easier writing and placement, 
// as well as more complex dialogue options being able to be implemented if needed using established methods
public class InkDialogueManager : MonoBehaviour
{
    [Header("Dialogue UI")]
    [SerializeField] private GameObject dialogueBox;
    [SerializeField] private Animator dialogueBoxAnimator;

    [SerializeField] private Button next;

    [SerializeField] private TextMeshProUGUI dialogueText;
    [SerializeField] private TextMeshProUGUI nameText;
    [SerializeField] private Animator playerPortraitAnimator;
    [SerializeField] private Animator npcPortraitAnimator;
    [SerializeField] private Animator showCasePortraitAnimator;
    
    [Header("Misc")]
    
    [SerializeField] private float typeSpeed = 0.06f;

    private Story currentStory;
    
    private bool dialogueIsActive = false;

    private bool canPressContinue = true;

    private bool submit = false;

    private static InkDialogueManager instance;

    // Tags to look for in the ink files
    private const string SPEAKER_TAG = "speaker";
    private const string PLAYERPORTRAIT_TAG = "playerPortrait";
    private const string NPCPORTRAIT_TAG = "npcPortrait";
    private const string SHOWCASEPORTRAIT_TAG = "showcasePortrait";
    private const string LAYOUT_TAG = "layout";
    private const string SFX_TAG = "sfx";
    private const string MUSIC_TAG = "music";
    private const string EVENT_TAG = "event";

    private Coroutine typeSentenceCoroutine; // Set This to keep track if the coroutine is running to prevent multiple instances

    // Current Npc Movement
    private NPCMove npcMove;

    [SerializeField] private GameObject panel; 

    private void Awake()
    {
        instance = this;
        dialogueIsActive = false;
        dialogueBox.SetActive(false);
    }
    
    public static InkDialogueManager GetDialogueManager()
    {
        return instance;
    }

    public void StartDialogue(TextAsset inkJSON)
    {
        // disable control
        if (GameManager.LevelManager != null)
        {
            GameManager.LevelManager.isPaused = true;
            GameManager.LevelManager.ActiveUI(false);
            GameManager.player.MoveState(false, false);
        }
        //listen for input
        GameManager.player.inputActions.UI.Enable();
        GameManager.player.inputActions.UI.Submit.performed += ctx => DisplayNextSentence();
        
        currentStory = new Story(inkJSON.text);
        dialogueBox.SetActive(true);
        
        playerPortraitAnimator.gameObject.SetActive(true);
        npcPortraitAnimator.gameObject.SetActive(true);
        showCasePortraitAnimator.gameObject.SetActive(true);
        panel.SetActive(false);
        
        dialogueBoxAnimator.SetBool("IsOpen", true);

        nameText.text = "";
        playerPortraitAnimator.Play("default"); // grey state
        npcPortraitAnimator.Play("default"); // grey state
        showCasePortraitAnimator.Play("default"); // grey state

        DisplayNextSentence();
    }
    public void StartDialogue(TextAsset inkJSON,NPCMove m)
    {
        npcMove = m;
        StartDialogue(inkJSON);
    }

    public void DisplayNextSentence()
    {
        if (!canPressContinue && dialogueIsActive)
        {
            submit = true;
            return;
        }
        
        if (currentStory.canContinue)
        {
            // Stop the previous typing before starting a new one
            if (typeSentenceCoroutine != null)
            {
                StopCoroutine(typeSentenceCoroutine);
            }
            typeSentenceCoroutine = StartCoroutine(TypeSentence(currentStory.Continue()));
            HandleTags(currentStory.currentTags);
        }
        else
        {
            EndDialogue();
        }
    }

    private void HandleTags(List<string> tags)
    {
        foreach (string tag in tags)
        {
            string[] tagParts = tag.Split(':');
            
            if (tagParts.Length != 2)
            {
                Debug.LogError("Invalid tag: " + tag);
                continue;
            }
            
            string tagKey = tagParts[0].Trim();
            string tagValue = tagParts[1].Trim();

            switch (tagKey)
            {
                case SPEAKER_TAG:
                    // Set the speaker name
                    nameText.text = tagValue;
                    break;
                case PLAYERPORTRAIT_TAG:
                    // Set the player portrait
                    playerPortraitAnimator.Play(tagValue);
                    break;
                case NPCPORTRAIT_TAG:
                    // Set the speaker portrait
                    npcPortraitAnimator.Play(tagValue);
                    break;
                case SHOWCASEPORTRAIT_TAG:
                    // Set the showcase portrait
                    showCasePortraitAnimator.Play(tagValue);
                    if (tagValue != "default")
                    {
                        panel.SetActive(true);
                    }
                    else
                    {
                        panel.SetActive(false);
                    }
                    break;
                case LAYOUT_TAG:
                    // Set the layout, (If popups were to change the layout or anything)
                    break;
                case SFX_TAG:
                case MUSIC_TAG:
                    // Play the audio
                    GameManager.AudioManager.Play(tagValue);
                    break;
                case EVENT_TAG:
                    // Trigger the event
                    GameManager.EventManager.PlayEvent(tagValue);
                    break;
            }

        }
    }
        
    private IEnumerator TypeSentence(string sentence)
    {
        dialogueText.text = sentence;
        dialogueText.maxVisibleCharacters = 0;
        canPressContinue = false;
        dialogueIsActive = true;
        next.gameObject.SetActive(false);
        bool isTag = false; // For text tags such as colour, bold etc
        
        foreach (char letter in sentence.ToCharArray())
        {
            // When the player presses a key this would skip the typing effect
            if (submit)
            {
                dialogueText.maxVisibleCharacters = sentence.Length;
                break;
            }
            if (letter == '<' || isTag)
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
                yield return new WaitForSeconds(typeSpeed);
            }
    
        }

        // Show Continue icon 
        next.gameObject.SetActive(true);
        canPressContinue = true;
        submit = false;
        dialogueIsActive = false;
    }

    private void EndDialogue()
    {
        dialogueIsActive = false;
        
        playerPortraitAnimator.gameObject.SetActive(false);
        npcPortraitAnimator.gameObject.SetActive(false);
        showCasePortraitAnimator.gameObject.SetActive(false);
        dialogueBoxAnimator.SetBool("IsOpen", false);
        
        dialogueBox.SetActive(false);
        
        dialogueText.text = "";
        
        // Enable control
        GameManager.LevelManager.isPaused = false;
        GameManager.LevelManager.ActiveUI(true);
        GameManager.player.MoveState(true, true);
        
        //stop listening for input
        GameManager.player.inputActions.UI.Submit.performed -= ctx => DisplayNextSentence();
        GameManager.player.inputActions.UI.Disable();
        if (npcMove != null && npcMove.GetLastState() != 3)
        {
            npcMove.SetState(0);
            npcMove = null;
        }
        else if (npcMove != null && npcMove.GetLastState() == 3)
        {
            npcMove.SetState(3);
            npcMove.Patrol();
            npcMove = null;
        }
    }
}
