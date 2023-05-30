using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class OnEnableSelect : MonoBehaviour
{
    [SerializeField] private Button button;
    [SerializeField] private bool force = false;
    
    [SerializeField] private bool realForce = false;
    private void OnEnable()
    {
        button.Select();
    }
    
    private void Update()
    {
        if (GameManager.input != null && GameManager.input.currentControlScheme != "Keyboard&Mouse" && force)
        {
            button.Select();
        }
        else if (realForce)
        {
            button.Select();
        }
    }
}
