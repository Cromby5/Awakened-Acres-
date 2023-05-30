using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using Cinemachine;

public class CineMachineCamera : MonoBehaviour
{
    public CinemachineVirtualCamera vcam; // current camera
    public CinemachineVirtualCamera[] cameraOffsets;

    private int count = 0;

    private void Awake()
    {
        GameManager.cinemachineCamera = this;
    }
    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        //vcam.Follow = GameManager.player.transform;
    }
    
    public void ChangeCameraAndLock(CinemachineVirtualCamera newCam)
    {
        vcam = newCam;
        vcam.enabled = true;
        GameManager.player.MoveState(false,false);
    }

    public void ChangeOffset()
    {
        if (GameManager.LevelManager.isPaused) return;
        count++;
        if (count >= cameraOffsets.Length)
        {
            count = 0;
        }
        for (int i = 0; i < cameraOffsets.Length; i++)
        {
            cameraOffsets[i].enabled = false;
        }
        cameraOffsets[count].enabled = true;
        vcam = cameraOffsets[count];
    }

    public void ResetCam()
    {
        cameraOffsets[count].enabled = true;
        vcam = cameraOffsets[count];
        bool i = GameManager.player.CurrentControllerState();
        GameManager.player.MoveState(!i, true);
    }

}
