using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class RadialWheelCenter : MonoBehaviour
{
    // This is the piviot point for the radial wheel, 
    // it should look at the mouse pos or for gamepad look in the direction of the stick
    [SerializeField] Vector2 aim;
    void Start()
    {
        
    }

    void Update()
    {
        //Input()
        Rotate();
    }
    
    public void Input(Vector2 dir)
    {
        aim = dir;
    }   
    
    void Rotate()
    {
        // If gamepad is the input look in the direction of the stick
        float angle = Mathf.Atan2(aim.y, aim.x) * Mathf.Rad2Deg - 90f;
        transform.rotation = Quaternion.AngleAxis(angle, Vector3.forward);
    }
}
