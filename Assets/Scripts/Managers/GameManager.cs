using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.InputSystem;
using UnityEngine.UI;

public class GameManager : MonoBehaviour
{
    // Should have done these per script to make their own instance
    public static GameManager instance;
    public static LevelManager LevelManager;
    public static DialogueManager DialogueManager;
    public static AudioManager AudioManager;
    public static EventManager EventManager;

    public static FarmManager FarmManager;
    public static MazeManager MazeManager;


    public static PlayerMovement player;
    public static PlayerInput input;
    public static PlayerInteraction playerInteract;

    public static CineMachineCamera cinemachineCamera;

    public static GamepadCursor gamepadCursor;

    public static Transform Spawn;
    //public static ItemManager itemManager;
    //public static TileManager tileManager;

    public Material skybox_a;
    public Material skybox_b;

    public List<GameObject> crops = new List<GameObject>();

    public static JournelEnable je;

    public static SwitchSky switchSky;

    public static DialogueReferences dialogueReferences;


    private void Awake()
    {
        if (instance != null && instance != this)
        {
            Destroy(gameObject);
        }
        else
        {
            instance = this;
        }
        DontDestroyOnLoad(gameObject);
       
    }

    public void Pause()
    {
        if (!player.canInput)
            return;
        
        if (LevelManager != null)
        {
            if (LevelManager.pauseUi.activeSelf)
            {
                LevelManager.pauseUi.SetActive(false);
                LevelManager.isPaused = false;
                //player.inputActions.UI.Disable();
            }
            else
            {
                LevelManager.pauseUi.SetActive(true);
                LevelManager.isPaused = true;
                //player.inputActions.UI.Enable();
            }
        }
    }

}
