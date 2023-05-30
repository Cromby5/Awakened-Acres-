using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CheckPoints : MonoBehaviour
{
    
    public List<GameObject> CheckPointsList = new List<GameObject>();
    
    private void Awake()
    {
        GameManager.Spawn = gameObject.transform;
    }
    // Start is called before the first frame update

    // Update is called once per frame
    void Update()
    {
        
    }
}
