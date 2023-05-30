using Cinemachine;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class FarmManager : MonoBehaviour
{
    // Actually losing it btw, about to be featured for most embarassing code after tonight
    public GameObject carrotNPC;
    public GameObject chilliNPC;
    public GameObject cherryNPC;
    public GameObject onionNPC;

    public Chest chest;
    
    // Last Gate, continuing this put it in and leave it as I will never touch this in a few days trend
    public GameObject Gate;
    public GameObject Rubble;
    public CinemachineVirtualCamera explodeCam;
    public GameObject fire;

    public Chest finalChest;


    private void Awake()
    {
        GameManager.FarmManager = this;
    }
    
}
