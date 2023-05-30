using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class CurrentInteraction : MonoBehaviour
{
    Camera cam;

    private void Start()
    {
        cam = Camera.main;
    }
    private void Update()
    {
        if (cam != null)
        {
            transform.LookAt(transform.position + cam.transform.rotation * Vector3.back, cam.transform.rotation * Vector3.up);
        }
    }
     
}
