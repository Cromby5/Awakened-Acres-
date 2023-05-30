using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class PlayerInteraction : MonoBehaviour
{
    private CharacterController playerController;

    public AbilityBar abilityBar;

    // the land the player has highlighted
    public Land selectedLand = null;

    public SelectBase otherSelect = null;

    public List<BaseSpell> tools = new List<BaseSpell>();

    public List<BaseSpell> spells = new List<BaseSpell>();

    public int selectedTool = 0;
    
    [SerializeField] private GameObject lights;

    [SerializeField] private LayerMask layerMask;

    [SerializeField] private DisplayCurrentSpell DisplayCurrentInteract;

    [Header("Spell Unlocks")]
    // Spell unlocks to match with select index
    // 0: Onion, 1: N/A, 2: Light, 3: Fire 4: Bomb
    public bool[] unlocks = new bool[4];

    [SerializeField] private DisplayCurrentSpell DisplayCurrentSpell;

    public bool underLight = false;

    [SerializeField] private Transform cherryPlace;

    public BaseSpell BaseSpell
    {
        get => default;
        set
        {
        }
    }
    private void Awake()
    {
        GameManager.playerInteract = this;
    }
    // Start is called before the first frame update
    void Start()
    {
        playerController = transform.parent.GetComponent<CharacterController>();
    }

    // Update is called once per frame
    void Update()
    {
        RaycastHit hit;
        if (Physics.Raycast(transform.position, Vector3.down, out hit, 3, layerMask))
        {
            OnInteractableHit(hit);
        }
        else if (selectedLand != null)
        {
            selectedLand.Select(false);
            DisplayCurrentInteract.ChangeImage(0);
            selectedLand = null;
        }
    }

    // When raycast meets interactable object
    void OnInteractableHit(RaycastHit hit)
    {
        Collider other = hit.collider;

        //Check if the player is going to interact with land
        if (other.CompareTag("Land"))
        {
            //Get the land component
            Land land = other.GetComponent<Land>();
            SelectLand(land);
            return;
        }

        if (selectedLand != null)
        {
            selectedLand.Select(false);
            selectedLand = null;
        }
    }

    //Handles the selection process
    void SelectLand(Land land)
    {
        //Set the previously selected land to false (If any)
        if (selectedLand != null)
        {
            selectedLand.Select(false);
        }

        //Set the new selected land to the land we're selecting now. 
        selectedLand = land;
        DisplayCurrentInteract.ChangeImage(land.toolShow);
        land.Select(true);
    }

    // Detects interaction when interact key is pressed
    public void Interact()
    {
        if (GameManager.LevelManager.isPaused == false && GameManager.player.canInput)
        {
            // Check if farmable land
            /*
            if (selectedLand != null)
            {
                selectedLand.Interact();
                return;
            }
            */
            Debug.Log("Not farmable land");
            // AXE throw away implementation, THIS Will be an issue soon
            if (otherSelect != null)
            {
                otherSelect.Interact();
                return;
            }
        }
    }
    public void UseSpell()
    {
        if (GameManager.LevelManager.isPaused == true)
            return;
        if (GameManager.player.canInput == false)
            return;
     
        if (spells[selectedTool].isActiveAndEnabled && abilityBar.GetSliderValue() > 0)
        {
            Debug.Log("Spell: " + spells[selectedTool].spellData.itemName);
            GameManager.player.animator.SetTrigger("isCast");
            switch (spells[selectedTool].spellData.itemName)
            {
                case "Fire":
                    GameManager.AudioManager.Play("Fire Spell");
                    GameObject fire = Instantiate(spells[selectedTool].spellData.itemPrefab, transform.position + transform.up, transform.rotation);
                    abilityBar.AbilityBarDecrease(spells[selectedTool].spellData.spellCost);
                    spells[selectedTool].ChangeMana((int)abilityBar.GetSliderValue());
                    break;
                case "Light":
                    GameManager.AudioManager.Play("Light Spell");
                    if (lights.activeSelf)
                    {
                        //lights.SetActive(false);
                        return;
                    }
                    else
                    {
                        lights.SetActive(true);
                        lights.GetComponent<lightTimer>().StartTimer();
                        // Add lantern activation???
                        // sphere cast
                        if (Physics.OverlapSphere(playerController.transform.position, 1f).Length > 0)
                        {
                            foreach (Collider hit in Physics.OverlapSphere(playerController.transform.position, 1f))
                            {
                                if (hit.CompareTag("LaserBase"))
                                {
                                    hit.GetComponent<LaserBeam>().TurnOn();
                                    lights.SetActive(false);
                                }
                            }
                        }
                        abilityBar.AbilityBarDecrease(spells[selectedTool].spellData.spellCost);
                        spells[selectedTool].ChangeMana((int)abilityBar.GetSliderValue());
                    }
                    break;
                case "Cherry Bomb":
                    //GameManager.AudioManager.Play("Bomb Spell");
                    // check sphere
                    if (Physics.CheckSphere(cherryPlace.position, 0.5f))
                    {

                    }
                    else
                    {
                        Instantiate(spells[selectedTool].spellData.itemPrefab, cherryPlace.position, cherryPlace.rotation);
                        abilityBar.AbilityBarDecrease(spells[selectedTool].spellData.spellCost);
                        spells[selectedTool].ChangeMana((int)abilityBar.GetSliderValue());
                    }

                    //Instantiate(spells[selectedTool].spellData.itemPrefab, transform.position, transform.rotation);
                    // AbilityBarDecrease(spells[selectedTool].spellData.spellCost);
                    break;

                case "Onion":
                    GameManager.AudioManager.Play("Water Spell");
                    Instantiate(spells[selectedTool].spellData.itemPrefab, transform.position + transform.up, transform.rotation);
                    abilityBar.AbilityBarDecrease(spells[selectedTool].spellData.spellCost);
                    spells[selectedTool].ChangeMana((int)abilityBar.GetSliderValue());
                    break;
                case "Farming":
                    if (selectedLand != null)
                    {
                        selectedLand.Interact();
                        return;
                    }
                    break;
            }
        }
        else if (abilityBar.GetSliderValue() <= 0)
        {
            Debug.Log("Not enough mana");
            if (spells[selectedTool].spellData.itemName == "Farming")
            {
                if (selectedLand != null)
                {
                    selectedLand.Interact();
                    return;
                }
            }
        }

    }
    
    public void SwitchSpell(int index)
    {
        if (GameManager.LevelManager.isPaused || !GameManager.player.canInput)
            return;

        if (index == spells.Count)
            index = 0;
        if (index == -1)
            index = spells.Count - 1;

        if (unlocks[index] == false)
            return;
        spells[selectedTool].ChangeMana((int)abilityBar.GetSliderValue());
        selectedTool = index;
        DisplayCurrentSpell.ChangeImage(selectedTool);
        if (selectedTool >= spells.Count)
        {
            selectedTool = 0;
        }
        for (int i = 0; i < spells.Count; i++)
        {
            if (i == selectedTool)
            {
                spells[i].gameObject.SetActive(true); // Sets the selected weapon to be active
                tools[i].gameObject.SetActive(false);
                //slider.value = spells[i].RemainingMana;
            }
            else
            {
                tools[i].gameObject.SetActive(false); // Sets the tools not selected to false
                spells[i].gameObject.SetActive(false); // Sets the spells not selected to false
            }
        }
    }

    public int GetSelectedTool()
    {
        return selectedTool;
    }

    public void Unlock(int i)
    {
        unlocks[i] = true;
        switch (i)
        {
            case 0:
                //no onion rip, makes the following look stupid
            break;
                
            case 1:
                //farm
                DisplayCurrentSpell.UnHideSpell(0);
            break;
                
            case 2:
                //light
                DisplayCurrentSpell.UnHideSpell(1);
            break;

            case 3:
                //fire
                DisplayCurrentSpell.UnHideSpell(2);
            break;

            case 4:
                //bomb
                DisplayCurrentSpell.UnHideSpell(3);
            break;

        }
          
    }

    public bool IsLights(bool lightState)
    {
        if (lights.activeSelf)
        {
            lights.SetActive(lightState);
            return true;
        }
        else
        {
            return false;
        }
    }    
}


