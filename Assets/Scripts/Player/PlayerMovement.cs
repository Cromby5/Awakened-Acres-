using System.Collections;
using System.Collections.Generic;
using System.Threading;
using UnityEngine;
using UnityEngine.InputSystem;

public class PlayerMovement : MonoBehaviour
{
   
    public InputActions inputActions = null;
    
    private CharacterController controller;
    public Vector3 playerVelocity;
    private bool groundedPlayer;
    [Header("Player Movement")]
    [SerializeField] private float playerSpeed = 2.0f;
    [SerializeField] private float gravityValue = 0.0f;
    [SerializeField] private float pushForce = 1.0f;

    public bool canInput = true;
    
    public bool isLocked = false;
    
    public Vector3 GetPlayerSpeed()
    {
        return playerVelocity;
    }

    private PlayerInteraction playerInteraction;
    [SerializeField] private Inventory_UI playerInv;
    
    //[SerializeField] private PlayerCamera playerCam;
    [SerializeField] private CineMachineCamera playerCam;

    [SerializeField] private RadialWheelCenter radWheel;
    public Vector3 move { get; private set;}

    public Animator animator;
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
        //inputActions.Player.SpellWheel.performed += ctx => GameManager.LevelManager.SpellWheelToggle();
        //inputActions.Player.SwapSpellL.performed += ctx => playerInteraction.SwitchSpell(playerInteraction.selectedTool + 1);
        //inputActions.Player.SwapSpellR.performed += ctx => playerInteraction.SwitchSpell(playerInteraction.selectedTool - 1);
        //inputActions.Player.ToolWheel.performed += ctx => GameManager.LevelManager.ToolWheelToggle();
        inputActions.Player.UpFarm.performed += ctx => playerInteraction.SwitchSpell(1);
        inputActions.Player.DownFire.performed += ctx => playerInteraction.SwitchSpell(3);
        inputActions.Player.LeftLight.performed += ctx => playerInteraction.SwitchSpell(2);
        inputActions.Player.RightBomb.performed += ctx => playerInteraction.SwitchSpell(4);

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
        //inputActions.Player.SpellWheel.performed -= ctx => GameManager.LevelManager.SpellWheelToggle();
        //inputActions.Player.ToolWheel.performed -= ctx => GameManager.LevelManager.ToolWheelToggle();
        //inputActions.Player.SwapSpellL.performed -= ctx => playerInteraction.SwitchSpell(playerInteraction.selectedTool + 1);
        //inputActions.Player.SwapSpellR.performed -= ctx => playerInteraction.SwitchSpell(playerInteraction.selectedTool - 1);
        inputActions.Player.UpFarm.performed -= ctx => playerInteraction.SwitchSpell(1);
        inputActions.Player.DownFire.performed -= ctx => playerInteraction.SwitchSpell(3);
        inputActions.Player.LeftLight.performed -= ctx => playerInteraction.SwitchSpell(2);
        inputActions.Player.RightBomb.performed -= ctx => playerInteraction.SwitchSpell(4);
        inputActions.Player.CameraSwitch.performed -= ctx => playerCam.ChangeOffset();

        inputActions.Player.Disable();
    }
    private void Awake()
    {
        GameManager.player = this;
        controller = gameObject.GetComponent<CharacterController>();
        playerInteraction = gameObject.GetComponentInChildren<PlayerInteraction>();

        animator = gameObject.GetComponentInChildren<Animator>();
    }

    private void Update()
    {
        groundedPlayer = controller.isGrounded;
        if (groundedPlayer && playerVelocity.y < 0)
        {
            playerVelocity.y = 0f;
        }

        if (GameManager.LevelManager.isPaused)
        {
            animator.SetFloat("Speed", 0);
        }
    }
    private void FixedUpdate()
    {
        if (GameManager.LevelManager.isPaused == false && controller.enabled == true)
        {
            Move();
        }
    }
    public void MoveInput(Vector2 input)
    {
        if (canInput)
        {
            move = new Vector3(input.x, 0, input.y);
        }
        else
        {
            move = Vector3.zero;
        }
    }

    private void Move()
    {
        controller.Move(playerSpeed * Time.deltaTime * move);
        animator.SetFloat("Speed", move.magnitude);

        if (move != Vector3.zero)
        {
            gameObject.transform.forward = move;
        }

        playerVelocity.y += gravityValue * Time.deltaTime;
        controller.Move(playerVelocity * Time.deltaTime);
    }

    public void MoveState(bool cState, bool iState)
    {
        controller.enabled = cState;
        canInput = iState;
        
        //playerInteraction.otherSelect.Select(false);
        //playerInteraction.otherSelect = null;
        
        if (cState == false)
            animator.SetFloat("Speed", 0); move = Vector3.zero;
    }
    
    public bool CurrentControllerState()
    {
        return isLocked;
    }


    private void OnControllerColliderHit(ControllerColliderHit hit)
    {
        if (hit.gameObject.CompareTag("Moveable"))
        {
            if (hit.collider.TryGetComponent<Rigidbody>(out var box))
            {
                Vector3 pushDir = new Vector3(hit.moveDirection.x, 0, hit.moveDirection.z);
                box.velocity = pushDir * pushForce;
            }
        }
        /*
        if (hit.gameObject.CompareTag("KnockBack"))
        {
            playerVelocity = new Vector3(hit.moveDirection.x, 0, hit.moveDirection.z);
        }
        */
    }
}
