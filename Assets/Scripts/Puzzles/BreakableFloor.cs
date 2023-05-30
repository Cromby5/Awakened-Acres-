using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class BreakableFloor : MonoBehaviour
{

    [SerializeField] private int count; // Amount of times player can step on this tile before it breaks
    private MeshRenderer meshRenderer;

    [SerializeField] private Material[] materials; // Materials for the floor states

    [SerializeField] private float timeToBreak;
    private float currentTimer;
    
    [SerializeField] private GameObject[] FloorStates;

    bool isBroke;
    bool isChange = false;

    [SerializeField] private Animator[] animators;

    private void Awake()
    {
        meshRenderer = GetComponent<MeshRenderer>();
       
    }
    
    void Start()
    {
        //StateChange();
    }

    void StateChange()
    {
        // Old
        /*
        if (count != -1)
        {
            Material[] tempMats = meshRenderer.materials;
            tempMats[0] = materials[count];
            meshRenderer.materials = tempMats;
        }
        */
        
        // New
        for (int i = 0; i < FloorStates.Length; i++)
        {
            if (i == count)
            {
                FloorStates[i].SetActive(true);
            }
            else
            {
                FloorStates[i].SetActive(false);
            }
        }
        isChange = false;
    }

    private void OnTriggerEnter(Collider other)
    {
        if (other.gameObject.CompareTag("Player") && count <= 0 && !isBroke)
        {
            isBroke = true;
            gameObject.SetActive(false);
        }
        else if (!isBroke)
        {
            Debug.Log("Player stepped on floor");
            //count--;
            //StateChange();
        }

    }

    private void OnTriggerStay(Collider other)
    {
        if (other.gameObject.CompareTag("Player") && !isBroke && !isChange)
        {
            //set animator bool to true
            animators[count].SetBool("Breaking", true);
            Debug.Log("Player staying on floor");
            currentTimer += Time.deltaTime;
            if (currentTimer >= timeToBreak)
            {
                isChange = true;
                currentTimer = 0;
                count -= 1;
                StateChange();
            }
        }

        if (other.gameObject.CompareTag("Player") && count <= 0 && !isBroke)
        {
            isBroke = true;
            gameObject.SetActive(false);
        }
    }

    private void OnTriggerExit(Collider other)
    {
        animators[count].SetBool("Breaking", false);
        currentTimer = 0;
    }

    private void OnDestroy()
    {
        
    }

    public void ResetFloor()
    {
        count = 2;
        currentTimer = 0;
        isBroke = false;
        isChange = false;
        gameObject.SetActive(true);
        StateChange();
    }

}
