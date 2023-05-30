using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using Cinemachine;

public class DoorSwitch : SelectBase
{
    [SerializeField] private DoorCode[] doorCode; // password
    [SerializeField] private DoorCode[] currentInput; // input
    [SerializeField] private int pressCount; // Current number when pressing
    [SerializeField] private int numOfPresses; // Limit of numbers
    private bool locked = false;
    private bool solved = false;

    [SerializeField] private Sprite[] codeToDisplay; // On s door

    [SerializeField] private GameObject doorToOpen;
    [SerializeField] private Image[] doorCodeDisplay;
    
    // what the UI shows
    [SerializeField] private GameObject[] selected;

    [SerializeField] private float buffertime;
    private float buffer;
    
    [SerializeField] private CinemachineVirtualCamera vCam;
    //private PlayerInteraction pI;

    //[SerializeField] private RadialMenu switchRadialMenu;
    private enum DoorCode
    {
        Onion,
        Nothing,
        Light,
        Fire,
        Bomb
    }

    void Start()
    {
        buffer = buffertime;
        doorCodeDisplay[0].sprite = codeToDisplay[(int)doorCode[0]];
        doorCodeDisplay[1].sprite = codeToDisplay[(int)doorCode[1]];
        currentInput = new DoorCode[doorCode.Length];
        //pI = GameManager.playerInteract;
        pressCount = 0;
        numOfPresses = doorCode.Length;
    }

    void Update()
    {
        if (buffertime >= 0)
        {
            buffertime -= Time.deltaTime;
        }
      
        if (pressCount == numOfPresses)
        {
            if ((int)currentInput[0] == (int)doorCode[0])
            {
                Debug.Log("1st number correct");
                if ((int)currentInput[1] == (int)doorCode[1])
                {
                    Debug.Log("2nd number correct");
                    GameManager.AudioManager.Play("Door Open");
                    StartCoroutine(Wait());
                    Close();
                }
                else
                {
                    Debug.Log("2nd number wrong");
                    Close();
                }
            }
            else
            {
                Debug.Log("1st number wrong");
                Close();
            }
        }

    }

    public override void Interact()
    {
        if (!solved && buffertime < 0)
        {
            if (locked && pressCount == numOfPresses)
            {
                Close();
            }
            else if (locked && pressCount != numOfPresses)
            {
                Value(GameManager.LevelManager.spellWheel.GetComponent<RadialMenu>().GetSelect());
            }
            else
            {
                locked = true;
                GameManager.player.MoveState(false, true);
                GameManager.player.isLocked = true;
                currentInput = new DoorCode[doorCode.Length];
                GameManager.LevelManager.SpellWheelToggle();
                GameManager.LevelManager.spellWheel.GetComponent<RadialMenu>().SetKeyDoor(this);
            }
            buffertime = buffer;
        }
    }

    private void Close()
    {
        locked = false;
        for (int i = 0; i < selected.Length; i++)
        {
            selected[i].SetActive(false);
        }
        pressCount = 0;
        currentInput = null;

        GameManager.player.MoveState(true, true);
        GameManager.player.isLocked = false;
        GameManager.LevelManager.SpellWheelToggle();
        GameManager.LevelManager.spellWheel.GetComponent<RadialMenu>().UnSetKeyDoor();
    }

    IEnumerator Wait()
    {
        GameManager.cinemachineCamera.ChangeCameraAndLock(vCam);
        yield return new WaitForSeconds(2f);
        doorToOpen.SetActive(false);
        solved = true;
        yield return new WaitForSeconds(1f);
        GameManager.cinemachineCamera.ResetCam();
        Destroy(gameObject);
    }

    public void Value(int i)
    {
        currentInput[pressCount] = (DoorCode)i;
        selected[i].SetActive(true);
        Debug.Log(currentInput[pressCount]);
        pressCount++;
    }

}
