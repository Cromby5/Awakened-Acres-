using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class OnionBehaviour : MonoBehaviour
{

    // Update is called once per frame
    void Update()
    {
        if (Input.GetButtonDown("Fire2"))
        {
            RaycastHit hit;
            Debug.DrawRay(gameObject.transform.position, transform.forward, Color.green);

            if (Physics.Raycast(transform.position, transform.forward, out hit))
            {
                if (hit.collider.gameObject.CompareTag("Fire"))
                {
                    Destroy(hit.collider.gameObject);
                }
            }
        }
    }
}

