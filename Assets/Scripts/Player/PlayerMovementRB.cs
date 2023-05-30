using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.InputSystem;

public class PlayerMovementRB : MonoBehaviour
{
    InputActions inputActions = null;
    private Rigidbody rigidPlayer; // Rigidbody of the player
    
    [SerializeField] private float speed; // The current speed the player is set at
    [SerializeField] private float rotateSpeed; // The rotation speed of the player 
    
    Vector3 moveDirection; // Direction the player moves in

    [SerializeField] private RadialWheelCenter radWheel;
    [SerializeField] private PlayerInteraction playerInteraction;
    [SerializeField] private Inventory_UI playerInv;
    [SerializeField] private CineMachineCamera playerCam;

    private void Awake()
    {
        rigidPlayer = GetComponent<Rigidbody>();
    }
    private void OnEnable()
    {
        inputActions = new InputActions();
        GameManager.input = GetComponent<PlayerInput>();
        inputActions.Player.Enable();
        // The list of InputActions on the player map to listen for and their respective functions that will be called when they are triggered through input
        inputActions.Player.Move.performed += ctx => MoveInput(ctx.ReadValue<Vector2>());
        inputActions.Player.Move.canceled += ctx => MoveInput(Vector2.zero);
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
        inputActions.Player.Move.performed -= ctx => MoveInput(ctx.ReadValue<Vector2>());
        inputActions.Player.Move.canceled -= ctx => MoveInput(Vector2.zero);
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

    void Update()
    {

    }
    private void FixedUpdate()
    {
        // Physics related code goes here
        Move(); // Physics of the player moving seperated to FixedUpdate to provide consistant movement not tied to the framerate
    }

    private void Move()
    {
        rigidPlayer.AddForce(moveDirection.normalized * speed, ForceMode.Acceleration); // Add the force to move the player
        if (moveDirection != Vector3.zero)
        {
            transform.rotation = Quaternion.RotateTowards(transform.rotation, Quaternion.LookRotation(moveDirection), rotateSpeed); // Start to rotate in the direction of movement at the speed of rotation 
        }
    }
    void MoveInput(Vector2 input)
    {
        moveDirection = new Vector3(input.x, 0, input.y);
    }

    
}
