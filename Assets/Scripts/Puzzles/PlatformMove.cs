using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PlatformMove : MonoBehaviour
{
    [SerializeField] private float speed = 1.0f;
    [SerializeField] private Transform targetA,targetB;
    private bool switchTarget = false;

    private void FixedUpdate()
    {
        if (!switchTarget)
        {
            transform.position = Vector3.MoveTowards(transform.position, targetA.position, speed * Time.deltaTime);
            if (transform.position == targetA.position)
            {
                switchTarget = true;
            }
        }
        else
        {
            transform.position = Vector3.MoveTowards(transform.position, targetB.position, speed * Time.deltaTime);
            if (transform.position == targetB.position)
            {
                switchTarget = false;
            }
        }

    }
}
