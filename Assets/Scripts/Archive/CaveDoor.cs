using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CaveDoor : MonoBehaviour
{
    public Transform door;
    public float moveDistance;
    public float moveSpeed;

    private Vector3 initialPosition;
    private Vector3 targetPosition;
    private bool isOpen = false;

    private void Start()
    {
        initialPosition = door.position;
        targetPosition = initialPosition + Vector3.up * moveDistance;
        Physics.IgnoreCollision(door.GetComponent<Collider>(), GetComponent<Collider>());
    }

    private void OnTriggerEnter(Collider other)
    {
        if (!isOpen && other.CompareTag("Player"))
        {
            isOpen = true;
            StartCoroutine(MoveDoor());
        }
    }

    private void OnTriggerExit(Collider other)
    {
        if (isOpen && other.CompareTag("Player"))
        {
            isOpen = false;
            StartCoroutine(MoveDoor());
        }
    }

    private IEnumerator MoveDoor()
    {
        float t = 0f;
        Vector3 startPos = door.position;
        Vector3 targetPos = isOpen ? targetPosition : initialPosition;

        while (t < 1f)
        {
            t += Time.deltaTime * moveSpeed;
            door.position = Vector3.Lerp(startPos, targetPos, t);
            yield return null;
        }
    }
}
