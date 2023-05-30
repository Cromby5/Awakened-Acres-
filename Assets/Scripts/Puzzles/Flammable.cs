using System.Collections;
using System.Collections.Generic;
using Unity.VisualScripting;
using UnityEngine;

public class Flammable : MonoBehaviour, IDataPersist
{
  enum FlammableType
    {
        Normal,
        Torch,
        Enviroment,
    }
    
    [SerializeField] private FlammableType flammableType;
    [SerializeField] private float burnRadius;
    private GameObject lights;
    [SerializeField] private float burnTime; // Time until the object is destroyed
    private ParticleSystem fireParticles; // The fire particles
    [SerializeField] private bool burning = false; // Bool to check if the object is burning
    [SerializeField] private bool checkPoint = true; // Bool to check if the object should be a checkpoint
    [SerializeField] private Transform respawn;

    [SerializeField] private GameObject lightR;
    


    // Start is called before the first frame update
    void Start()
    {
        fireParticles = GetComponentInChildren<ParticleSystem>();
        if (flammableType == FlammableType.Torch)
        {
            lights = transform.GetChild(0).gameObject;
            lights.SetActive(false);
            lightR.SetActive(false);
        }

        if (burning)
        {
            Burn();
        }
    }

    // Update is called once per frame
    void Update()
    {
        if (burning && flammableType == FlammableType.Normal)
        {
            Collider[] hitColliders = Physics.OverlapSphere(transform.position, burnRadius);
            foreach (var hitCollider in hitColliders)
            {
                if (hitCollider.gameObject.CompareTag("Flammable"))
                {
                    hitCollider.gameObject.GetComponent<Flammable>().Burn();
                }
            }
        }
    }

    public void LoadData(GameData data)
    {
        
    }

    public void SaveData(GameData data)
    {
       
    }

    public void Burn()
    {
        if (flammableType == FlammableType.Torch && lights.activeSelf)
            return;

        burning = true;
        GameManager.AudioManager.Play("Burning");
        if (flammableType == FlammableType.Torch && respawn != null)
        {
            if (checkPoint)
            GameManager.LevelManager.SetTorchCheckPoints(respawn);
            
            lightR.SetActive(true);
        }
        StartCoroutine(Timer());
    }

    public void Extinguish()
    {
        fireParticles.Stop();
        if (flammableType == FlammableType.Torch)
        {
            lights.SetActive(false);
        }
        burning = false;
        if (flammableType == FlammableType.Enviroment)
        {
            Destroy(gameObject);
        }
    }

    IEnumerator Timer()
    {
        fireParticles.Play();
        if (flammableType == FlammableType.Torch)
        {
            lights.SetActive(true);
        }
        yield return new WaitForSeconds(burnTime);
        if (flammableType == FlammableType.Normal)
        {
            Destroy(gameObject);
        }
    }
    private void OnDrawGizmos()
    {
          Gizmos.DrawWireSphere(transform.position, burnRadius);
    }

}

