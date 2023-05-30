using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MazeManager : MonoBehaviour
{
    public GameObject carrotNpc;
    public GameObject portal;
    void Awake()
    {
        GameManager.MazeManager = this;
    }
}
