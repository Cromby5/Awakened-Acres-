using System.Collections;
using System.Collections.Generic;
using System.Linq.Expressions;
using UnityEditor.Rendering;
using UnityEngine;
using UnityEngine.InputSystem;
using UnityEngine.UI;

public class RadialMenu : MonoBehaviour
{
    private Vector2 mousePos;
    private float angle;
    [SerializeField] private int selected;
    private int preselect;

    public GameObject[] menuItems;

    public Image currentImage;

    [SerializeField] private Slider manaPreview;

    public Sprite[] backgroundItems;

    private PlayerInteraction playerInteraction;

    private MenuItem menuItemsUI;
    private MenuItem premenuItemUI;

    [SerializeField] private bool isTool = false;
    [SerializeField] private bool isSpell, isKey = false;


    [SerializeField] private GameObject selector;

    private DoorSwitch switchDoor;

    private void OnEnable()
    {
        //gamepadCursor.cursorTransform.gameObject.SetActive(true);
    }
    private void OnDisable()
    {
        //gamepadCursor.cursorTransform.gameObject.SetActive(false);
        UseTool();
    }

    void Start()
    {
        playerInteraction = GameManager.playerInteract;
    }

    void Update()
    {
        if (GameManager.input.currentControlScheme == "Keyboard&Mouse")
        {
            mousePos = new Vector2(Input.mousePosition.x - Screen.width / 2, Input.mousePosition.y - Screen.height / 2);
        }
        else
        {
            // This actually took a stupid amount of time for me to realise what to do here for some reason, overcomplicating things is fun
            mousePos = new Vector2(selector.transform.position.x - Screen.width / 2, selector.transform.position.y - Screen.height / 2);
        }

        // Somewhere in update.
        angle = Mathf.Atan2(mousePos.y, mousePos.x) * Mathf.Rad2Deg;

        angle = (angle + 360) % 360;

        selected = (int)angle / (360 / menuItems.Length);

        if (selected != preselect)
        {
            premenuItemUI = menuItems[preselect].GetComponent<MenuItem>();
            premenuItemUI.Deselect();
            preselect = selected;
            menuItemsUI = menuItems[selected].GetComponent<MenuItem>();
            menuItemsUI.Select();
            currentImage.sprite = backgroundItems[selected];
            //manaPreview.value = playerInteraction.spells[selected].RemainingMana;
        }
    }

    void UseTool()
    {
        if (isTool)
        {
            Debug.Log("Using " + menuItems[selected].name);
            //playerInteraction.SwitchTool(selected);
            gameObject.SetActive(false);
        }
        else if (isSpell)
        {
            Debug.Log("Using GG " + menuItems[selected].name);
            playerInteraction.SwitchSpell(selected);
            gameObject.SetActive(false);
        }
        else if (isKey && switchDoor != null)
        {
            switchDoor.Value(selected);
            // Only close if the press count is the same as num of presses or something
            gameObject.SetActive(false);
        }
    }

    // Starting to hate myself for shit overides like this
    public void SetKeyDoor(DoorSwitch k)
    {
        switchDoor = k;
        isSpell = false;
        isKey = true;
    }

    public void UnSetKeyDoor()
    {
        switchDoor = null;
        isSpell = true;
        isKey = false;
    }

    public int GetSelect()
    {
        return selected;
    }
}