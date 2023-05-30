using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PlayerCamera : MonoBehaviour
{
    public Transform target;

    private Transform playerT; 

    public bool isCustomOffset;
    [SerializeField] private Vector3 currentOffset;

    [SerializeField] private Vector3[] offsetPositions;
    
    public float smoothSpeed = 0.1f;

    //public PlayerMovement playerMovement;

    CastTransparency wall;

    private bool smooth = false;
    
    private void Start()
    {
        playerT = target;
        // You can also specify your own offset from inspector
        // by making isCustomOffset bool to true
        if (!isCustomOffset)
        {
            currentOffset = transform.position - target.position;
        }
        else 
        {
            currentOffset = offsetPositions[0];
        }
    }

    private void LateUpdate()
    {
        if (smooth)
        {
            SmoothFollow();
        }
        else
        {
            Follow();
        }
        //Obstruction();
    }

    public void Follow()
    {
        transform.position = target.position + currentOffset;
        transform.LookAt(target);
    }
    public void SmoothFollow()
    {
        Vector3 targetPos = target.position + currentOffset;
        Vector3 smoothFollow = Vector3.Lerp(transform.position, targetPos, smoothSpeed);
        transform.position = smoothFollow;
        transform.LookAt(target);
    }
    
    public void LockAndPanTo(Transform focusTarget)
    {
        // Disable player movement  

        // Pan to target
        target = focusTarget;

        // Enable player movement when 1 second after it reaches destination 
        


    }

    // old method
    void Obstruction()
    {
        RaycastHit ray;

        if (Physics.Raycast(transform.position, target.position - transform.position,out ray, 10f) && ray.collider.gameObject.CompareTag("CanHide"))
        {
            wall = ray.transform.gameObject.GetComponent<CastTransparency>();
            wall.Apply();
        }
        else if (wall != null)
        {
            wall.Default();
        }
    }
    private void OnDrawGizmos()
    {
        Gizmos.DrawRay(transform.position, target.position - transform.position);
    }

    public void ChangeOffset()
    {
        if (GameManager.LevelManager.isPaused) return;
        smoothSpeed = 0.1f;
        smooth = true;
        if (currentOffset == offsetPositions[0])
        {
            currentOffset = offsetPositions[1];
        }
        else if (currentOffset == offsetPositions[1])
        {
            currentOffset = offsetPositions[0];
        }
        StartCoroutine(ChangeSmooth());
    }
    IEnumerator ChangeSmooth()
    {
        yield return new WaitForSeconds(0.5f);
        smoothSpeed = 1f;
        smooth = false;
    }
}
