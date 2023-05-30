  using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ShaderCircleFollow : MonoBehaviour
{
    public static int posID = Shader.PropertyToID("_PlayerPos");
    public static int sizeID = Shader.PropertyToID("_Size");

    public Material wallMat;
    public Material[] wallMats;
    public Camera cam;
    public LayerMask mask;
    
    void Update()
    {
        var dir = cam.transform.position - transform.position;
        var ray = new Ray(transform.position, dir.normalized);
        if (Physics.Raycast(ray, 3000, mask))
        {
            wallMat.SetFloat(sizeID, 1);
           /*
           foreach (Material mat in wallMats)
           {
               mat.SetFloat(sizeID, 1.3f);
           }
           */
        }
        else
        {
            wallMat.SetFloat(sizeID, 0);
           /*
           foreach (Material mat in wallMats)
           {
               mat.SetFloat(sizeID, 0);
           }
           */
        }
        var view = cam.WorldToViewportPoint(transform.position);
        wallMat.SetVector(posID, view);
        /*
        foreach (Material mat in wallMats)
        {
            mat.SetVector(posID, view);
        }
        */
    }
}
