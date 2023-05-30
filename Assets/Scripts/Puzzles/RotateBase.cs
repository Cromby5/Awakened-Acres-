using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class RotateBase : SelectBase
{
    private bool locked = false;
    private float currentTime;
    private float timeToRotate = 0.2f;

    [SerializeField] private LaserBeam laserBeam;

    // Start is called before the first frame update
    void Start()
    {
      
    }

    // Update is called once per frame
    void FixedUpdate()
    {
        if (locked)
        {
            currentTime += Time.deltaTime;
            //left
            if (GameManager.player.move.x <= -0.1f && currentTime > timeToRotate)
            {
                GameManager.player.animator.SetTrigger("isRotate");
                transform.Rotate(0, -30, 0);
                currentTime = 0;
            }
            //right
            if (GameManager.player.move.x >= 0.1f && currentTime > timeToRotate)
            {
                GameManager.player.animator.SetTrigger("isRotate");
                transform.Rotate(0, 30, 0);
                currentTime = 0;
            }
        }
    }
    
    public override void Interact()
    {
        if (laserBeam != null && GameManager.playerInteract.IsLights(false))
        {
            laserBeam.TurnOn();
            return;
        }
        
        if (!locked)
        {
            locked = true;
            // Change select material
            select.GetComponent<Renderer>().material = selectMat;
            //disable player 
            GameManager.player.MoveState(false,true);
            GameManager.player.isLocked = true;
        }
        else
        {
            select.GetComponent<Renderer>().material = defaultMat;
            locked = false;
            GameManager.player.MoveState(true,true);
            GameManager.player.isLocked = false;
        }
    }
}


