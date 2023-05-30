using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;
using System.Linq;

public class LevelManager : MonoBehaviour
{
    [Header("UI")]
    public GameObject craftingPanel;
    public GameObject pauseUi;
    public GameObject toolWheel;
    public GameObject spellWheel;

    // Mainly for When Dialogue is enabled
    [SerializeField] private GameObject inventoryPanel;
    [SerializeField] private GameObject spellShow;
    [SerializeField] private GameObject abilityBar;
    [SerializeField] private GameObject journelShow;

    public Inventory_UI inventoryUi;
    
    [Header("Misc")]
    public bool isPaused = false;

    public int currentZone = 0;

    [SerializeField] private int amountInTorchList;
    public List<Transform> torchCheckPoints = new List<Transform>();
    //{ get; private set; }

    private void Awake()
    {
        GameManager.LevelManager = this;
    }

    private void Start()
    {
        GameManager.AudioManager.Play("Farm Music");
    }

    private void Toggle(GameObject panel)
    {
        if (!panel.activeSelf)
        {
            panel.SetActive(true);
        }
        else
        {
            panel.SetActive(false);
        }
    }
    public void Menu()
    {
        Time.timeScale = 1;
        SceneManager.LoadScene("Menu");
    }
    public void CraftToggle()
    {
        Toggle(craftingPanel);
    }
    public void ToolWheelToggle()
    {
        Toggle(toolWheel);
        if (spellWheel.activeSelf)
        {
            spellWheel.SetActive(false);
        }
    }

    public void SpellWheelToggle()
    {
        if (!isPaused)
        {
            Toggle(spellWheel);
            if (toolWheel.activeSelf)
            {
                toolWheel.SetActive(false);
            }
        }
    }

    public void TorchCheckPoint()
    {
        GameManager.player.MoveState(false, false);
        GameManager.player.transform.position = torchCheckPoints[0].position;
        GameManager.player.MoveState(true, true);
    }
    
    public void SetTorchCheckPoints(Transform target)
    {
        if (torchCheckPoints.Count > amountInTorchList)
        {
            torchCheckPoints.RemoveAt(0);
        }
        torchCheckPoints.Add(target);
        
    }

    public void ActiveUI(bool t)
    {
        inventoryPanel.SetActive(t);
        spellShow.SetActive(t);
        abilityBar.SetActive(t);
        journelShow.SetActive(t);
    }
    
}
  
