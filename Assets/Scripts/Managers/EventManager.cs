using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class EventManager : MonoBehaviour
{
    // Prepare for a mess of objects here,
    [SerializeField] private MainMenu menu;
    // Not really how I wanted to do an eventmanager, This is just so tags in dialogue can activate some things. Skill put into queston after this
    [SerializeField] private GameObject camPan;

    //Journel Friend Pages
    [Header("Journel Friend Pages")]
    [SerializeField] private Image friendPage;
    [SerializeField] private GameObject chilliPageText;
    [SerializeField] private Sprite chilliPage;

    [SerializeField] private GameObject cherryPageText;
    [SerializeField] private Sprite cherryPage;

    //Journel Map Pages
    [Header("Journel Map Pages")]
    [SerializeField] private Image mapPage;
    [SerializeField] private Sprite mirrorDiscovered;
    [SerializeField] private Sprite mazeDiscovered;
    [SerializeField] private Sprite witchDiscovered;

    // Final
    [SerializeField] private GameObject endTab;
    [SerializeField] private GameObject logo;
    [SerializeField] private GameObject credits;
    private void Awake()
    {
        GameManager.EventManager = this;
    }
    public void PlayEvent(string tag)
    {
        Debug.Log("Event Played");
        switch (tag)
        {
            case "test":
                camPan.SetActive(true);
                break;
            case "test2":
                camPan.SetActive(false);
                break;
            // We need the following events to be triggered by dialogue.
            // Meeting Carrot/Chilli/Cherry updating journel. Journel gets updated after certain dialogues.
            // Carrot path change
            case "pat1":

                break;
            case "pat2":

                break;
            case "pat3":

                break;
                //NPCS
            case "carrotDisable":
                GameManager.FarmManager.carrotNPC.SetActive(false);
                break;
            case "carrotEnable":
                GameManager.FarmManager.carrotNPC.SetActive(true);
                break;
            case "carrotMaze":
                GameManager.MazeManager.carrotNpc.SetActive(false);
                GameManager.MazeManager.portal.GetComponent<Animator>().SetBool("isOpen", true);
                break;

            case "chiliEnable":
                friendPage.sprite = chilliPage;
                chilliPageText.SetActive(true);   
                GameManager.FarmManager.chilliNPC.SetActive(true);
                mapPage.sprite = mirrorDiscovered;
                break;

            case "cherryEnable":
                friendPage.sprite = cherryPage;
                cherryPageText.SetActive(true);
                GameManager.FarmManager.cherryNPC.SetActive(true);
                mapPage.sprite = mazeDiscovered;
                break;

            case "UnlockFarm":
                GameManager.playerInteract.Unlock(1);
                break;
            case "UnlockLight":
                GameManager.playerInteract.Unlock(2);
                break;
            case "UnlockFire":
                GameManager.playerInteract.Unlock(3);
                break;
            case "UnlockBomb":
                GameManager.playerInteract.Unlock(4);
                GameManager.FarmManager.finalChest.triggerOpen = true;
                break;

            case "GateExplode":
                //Explode gate
                StartCoroutine(GateExplode());
                GameManager.FarmManager.explodeCam.enabled = true;
                mapPage.sprite = witchDiscovered;
                break;
            case "ResetGateCam":
                GameManager.FarmManager.explodeCam.enabled = false;
                break;

            case "End":
                StartCoroutine(EndGame());
                break;

            default:
                Debug.LogError("Invalid tag: " + tag);
                break;
        }
    }
    IEnumerator GateExplode()
    {
        GameManager.FarmManager.Gate.GetComponent<Animator>().SetBool("isOpen", true);
        GameManager.FarmManager.fire.SetActive(true);
        yield return new WaitForSeconds(1.1f);
        GameManager.FarmManager.Gate.SetActive(false);
        GameManager.FarmManager.Rubble.SetActive(true);
        yield break;
    }

    IEnumerator EndGame()
    {
        endTab.SetActive(true);
        yield return new WaitForSeconds(5f);
        logo.SetActive(false);
        credits.SetActive(true);
        yield return new WaitForSeconds(10f);
        menu.ReturnMainMenu();
    }

}
