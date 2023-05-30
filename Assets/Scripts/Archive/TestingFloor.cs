using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class TestingFloor : MonoBehaviour
{
    public GameObject[] floor; // Array of floor states
    // Start is called before the first frame update
    void Start()
    {
        StartCoroutine(Wait());
    }

    IEnumerator Wait()
    {
        yield return new WaitForSeconds(2f);
        floor[0].SetActive(false);
        floor[1].SetActive(true);
        yield return new WaitForSeconds(2f);
        floor[1].SetActive(false);
        floor[2].SetActive(true);
    }

   
}
