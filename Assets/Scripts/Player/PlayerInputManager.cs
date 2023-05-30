using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.InputSystem;

public class PlayerInputManager : MonoBehaviour
{
    InputActions inputActions = null;

    [SerializeField] private PlayerInteraction playerInteraction = null;
    [SerializeField] private Inventory_UI playerInv = null;
    [SerializeField] private CineMachineCamera playerCam = null;
    [SerializeField] private RadialWheelCenter radWheel = null;

    private void OnEnable()
    {
        inputActions = new InputActions();
        GameManager.input = GetComponent<PlayerInput>();
        inputActions.Player.Enable();
        // The list of InputActions on the player map to listen for and their respective functions that will be called when they are triggered through input
        inputActions.Player.Move.performed += ctx => GameManager.player.MoveInput(ctx.ReadValue<Vector2>());
        inputActions.Player.Move.canceled += ctx => GameManager.player.MoveInput(Vector2.zero);
        inputActions.Player.RadialWheelAim.performed += ctx => radWheel.Input(ctx.ReadValue<Vector2>());
        inputActions.Player.RadialWheelAim.canceled += ctx => radWheel.Input(Vector2.zero);
        inputActions.Player.Interact.performed += ctx => playerInteraction.Interact();
        inputActions.Player.UseSpell.performed += ctx => playerInteraction.UseSpell();
        inputActions.Player.UseInvItem.performed += ctx => playerInv.Use(playerInv.selectedSlot);
        inputActions.Player.LeftB.performed += ctx => playerInv.ChangeEquipInverse();
        inputActions.Player.RightB.performed += ctx => playerInv.ChangeEquip();
        inputActions.Player.Pause.performed += ctx => GameManager.instance.Pause();
        inputActions.Player.SpellWheel.performed += ctx => GameManager.LevelManager.SpellWheelToggle();
        inputActions.Player.SwapSpellL.performed += ctx => playerInteraction.SwitchSpell(playerInteraction.selectedTool + 1);
        inputActions.Player.SwapSpellR.performed += ctx => playerInteraction.SwitchSpell(playerInteraction.selectedTool - 1);
        //inputActions.Player.ToolWheel.performed += ctx => GameManager.LevelManager.ToolWheelToggle();
        inputActions.Player.CameraSwitch.performed += ctx => playerCam.ChangeOffset();
    }

    private void OnDisable()
    {
        // Stop listening for player input
        inputActions.Player.Move.performed -= ctx => GameManager.player.MoveInput(ctx.ReadValue<Vector2>());
        inputActions.Player.Move.canceled -= ctx => GameManager.player.MoveInput(Vector2.zero);
        inputActions.Player.RadialWheelAim.performed -= ctx => radWheel.Input(ctx.ReadValue<Vector2>());
        inputActions.Player.RadialWheelAim.canceled -= ctx => radWheel.Input(Vector2.zero);
        inputActions.Player.Interact.performed -= ctx => playerInteraction.Interact();
        inputActions.Player.UseSpell.performed -= ctx => playerInteraction.UseSpell();
        inputActions.Player.UseInvItem.performed -= ctx => playerInv.Use(playerInv.selectedSlot);
        inputActions.Player.LeftB.performed -= ctx => playerInv.ChangeEquipInverse();
        inputActions.Player.RightB.performed -= ctx => playerInv.ChangeEquip();
        inputActions.Player.Pause.performed -= ctx => GameManager.instance.Pause();
        inputActions.Player.SpellWheel.performed -= ctx => GameManager.LevelManager.SpellWheelToggle();
        //inputActions.Player.ToolWheel.performed -= ctx => GameManager.LevelManager.ToolWheelToggle();
        inputActions.Player.CameraSwitch.performed -= ctx => playerCam.ChangeOffset();

        inputActions.Player.Disable();
    }
}
