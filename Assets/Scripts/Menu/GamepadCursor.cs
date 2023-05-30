using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.InputSystem;
using UnityEngine.InputSystem.LowLevel;
using UnityEngine.InputSystem.Users;

public class GamepadCursor : MonoBehaviour
{

    [SerializeField] private PlayerInput playerInput;
    [SerializeField] public RectTransform cursorTransform;
    [SerializeField] private Canvas canvas;
    [SerializeField] private RectTransform canvasRectTransform;
    //[SerializeField] private float cursorSpeed = 1000f;
    //[SerializeField] private float padding = 35f;

    public Vector2 globalpos;

    private Mouse vMouse;
    private Mouse currentMouse;
    private bool previousMouseState;

    private string previousControlScheme = "";
    private const string gamepadScheme = "Controller";
    private const string mouseScheme = "Keyboard";

    private void Awake()
    {
        GameManager.gamepadCursor = this;
    }

    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        if (previousControlScheme != playerInput.currentControlScheme)
        {
            OnControlsChanged(playerInput);
        }
        previousControlScheme = playerInput.currentControlScheme;
    }
    private void OnEnable()
    {
        currentMouse = Mouse.current;
        if (vMouse == null)
        {
            //vMouse = (Mouse)InputSystem.AddDevice("VirtualMouse");
        }
        else if (!vMouse.added)
        {
            //InputSystem.AddDevice("VirtualMouse");
        }
        //InputUser.PerformPairingWithDevice(vMouse, InputUser.all[0]);

        if (cursorTransform != null)
        {
            //Vector2 cursorPos = cursorTransform.anchoredPosition;
            //InputState.Change(vMouse.position, cursorPos);

        }
        InputSystem.onAfterUpdate += UpdateMotion;
        playerInput.onControlsChanged += OnControlsChanged;
    }
    private void OnDisable()
    {
        if (vMouse != null && vMouse.added) InputSystem.RemoveDevice(vMouse);
        InputSystem.onAfterUpdate -= UpdateMotion;
        playerInput.onControlsChanged -= OnControlsChanged;
    }
    private void UpdateMotion()
    {
        /*
        if (vMouse == null || Gamepad.current == null)
        {
            return;
        }
        Vector2 stickValue = Gamepad.current.rightStick.ReadValue();
        stickValue *= cursorSpeed * Time.unscaledDeltaTime;

        Vector2 currentPosition = vMouse.position.ReadValue();
        Vector2 newPosition = currentPosition + stickValue;

        newPosition.x = Mathf.Clamp(newPosition.x, padding, Screen.width - padding);
        newPosition.y = Mathf.Clamp(newPosition.y, padding, Screen.height - padding);

        InputState.Change(vMouse.position, newPosition);
        InputState.Change(vMouse.delta, stickValue);

        bool buttonState = Gamepad.current.xButton.isPressed;
        if (previousMouseState != buttonState)
        {
            vMouse.CopyState<MouseState>(out var mouseState);
            mouseState.WithButton(MouseButton.Left, buttonState);
            InputState.Change(vMouse, mouseState);
            previousMouseState = buttonState;
        }

        AnchorCursor(newPosition);
        globalpos = newPosition;
        */
        
    }
    void AnchorCursor(Vector2 position)
    {
        Vector2 anchoredPosition;
        RectTransformUtility.ScreenPointToLocalPointInRectangle(canvasRectTransform, position, canvas.renderMode == RenderMode.ScreenSpaceOverlay ? null : Camera.main, out anchoredPosition);
        cursorTransform.anchoredPosition = anchoredPosition;
    }
    private void OnControlsChanged(PlayerInput playerInput)
    {
        if (playerInput.currentControlScheme == mouseScheme && previousControlScheme != mouseScheme)
        {
            Debug.Log("Mouse");
           //cursorTransform.gameObject.SetActive(false);
            Cursor.visible = true;
            currentMouse.WarpCursorPosition(vMouse.position.ReadValue());
            previousControlScheme = mouseScheme;
        }
        else if (playerInput.currentControlScheme == gamepadScheme && previousControlScheme != gamepadScheme)
        {
            Debug.Log("Gamepad");
            //cursorTransform.gameObject.SetActive(true);
            Cursor.visible = false;
            InputState.Change(vMouse.position, currentMouse.position.ReadValue());
            AnchorCursor(currentMouse.position.ReadValue());
            previousControlScheme = gamepadScheme;
        }

    }

    public bool isMouse()
    {
        if (playerInput.currentControlScheme == mouseScheme)
        {
            return true;
        }
        else
        {
            return false;
        }
    }
}
