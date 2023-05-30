using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class TerrainManager : MonoBehaviour
{
    public float x_Start, y_Start;
    public int ColumnLength;
    public int RowLength;
    public int x_Space, y_Space;
    public GameObject prefab;
    
    void Awake()
    {
        for (int i = 0; i < ColumnLength * RowLength; i++)
        {
            Vector3 position;
            position = new Vector3(x_Start + (x_Space * (i % ColumnLength)), 0, y_Start + (-y_Space * (i / ColumnLength)));
            Instantiate(prefab, position, Quaternion.identity, transform);
        }

    }
}