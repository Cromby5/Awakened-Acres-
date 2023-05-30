using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CastTransparency : MonoBehaviour
{
    public MeshRenderer mesh;
    public Material DefualtMaterial;
    public Material OpaqueMaterial;

    // Start is called before the first frame update
    void Start()
    {
        mesh = this.GetComponent<MeshRenderer>();
    }

    // Update is called once per frame
    void Update()
    {
        
    }

    public void Apply()
    {
        Material[] tempMats = mesh.materials;
        tempMats[0] = OpaqueMaterial;
        mesh.materials = tempMats;
    }
    public void Default()
    {
        Material[] tempMats = mesh.materials;
        tempMats[0] = DefualtMaterial;
        mesh.materials = tempMats;
    }
}
