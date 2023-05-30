using System.Collections;
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;
using UnityEngine.UI;

[RequireComponent(typeof(LineRenderer))]
public class LaserBeam : MonoBehaviour
{
    public int reflections; // Amount of times the laser can reflect
    public float maxLength; // Max length of the laser, to constrain where beam can go

    private LineRenderer lineRenderer;
    private Ray ray;
    private RaycastHit hit;
    private Vector3 direction;

    [SerializeField] private bool isActive = false;
    [SerializeField] private Material[] laserColours;

    [Header("UI")]
    [SerializeField] private Image currentContext;
    [SerializeField] private Sprite carrotContext;
    [SerializeField] private Sprite turnContext;

    private enum LaserType
    {
        Red,
        Blue,
        Green,
        Orange,
        Purple,
    }

    [SerializeField] private LaserType laserType;

    [Header("Debug")]
    [SerializeField] private bool showReflections = false;
    
    private void Awake()
    {
        lineRenderer = GetComponent<LineRenderer>();
        showReflections = false;
        switch (laserType)
        {
            case LaserType.Red:
                lineRenderer.material = laserColours[0];
                break;
            case LaserType.Blue:
                lineRenderer.material = laserColours[1];
                break;
            case LaserType.Green:
                lineRenderer.material = laserColours[2];
                break;
            case LaserType.Orange:
                lineRenderer.material = laserColours[3];
                break;
            case LaserType.Purple:
                lineRenderer.material = laserColours[4];
                break;
        }
    }

    private void Update()
    {
        if (isActive)
        {
            DrawLaser();
        }
        else
        {
            lineRenderer.positionCount = 0;
        }    
    }
    private void DrawLaser()
    {
        ray = new Ray(transform.position, transform.forward);

        lineRenderer.positionCount = 1;
        lineRenderer.SetPosition(0, transform.position);
        float remainingLength = maxLength;

        for (int i = 0; i < reflections; i++)
        {
            if (Physics.Raycast(ray.origin, ray.direction, out hit, remainingLength, 1, QueryTriggerInteraction.Ignore))
            {
                lineRenderer.positionCount += 1;
                lineRenderer.SetPosition(lineRenderer.positionCount - 1, hit.point);
                remainingLength -= Vector3.Distance(ray.origin, hit.point);
                ray = new Ray(hit.point, Vector3.Reflect(ray.direction, hit.normal));

                if (!hit.collider.CompareTag("Mirror") && !hit.collider.CompareTag("Target"))
                    break;

                if (hit.collider.CompareTag("Target") && i == reflections - 1 && !showReflections)
                {
                    hit.collider.GetComponent<LaserTarget>().ActivateTargets();
                    //isActive = false;
                    //currentContext.sprite = carrotContext;
                }
            }
            else
            {
                lineRenderer.positionCount += 1;
                lineRenderer.SetPosition(lineRenderer.positionCount - 1, ray.origin + ray.direction * remainingLength);
            }
        }

        
    }

    public bool TurnOn()
    {
        // This should activate when interacting with the lantern with light active
        isActive = true;
        currentContext.sprite = turnContext; 
        return isActive;
    }
    #if UNITY_EDITOR
    private void OnDrawGizmos()
    {

        if (!EditorApplication.isPlaying)
        { 
            lineRenderer = GetComponent<LineRenderer>();
            if (showReflections)
            {
                DrawLaser();
            }
            else
            {
                lineRenderer.positionCount = 0;
            }
        }
    }
    #endif
}




/*
public class LaserBeam : MonoBehaviour
{
    public Vector3 origin;
    public Vector3 direction;

    private RaycastHit rayInfo;

    private LaserBeam reflection;

    LineRenderer lineRenderer;
    // reflect count?
    // timer?

    // Start is called before the first frame update
    void Start()
    {
        rayInfo = new RaycastHit();  
    }
  
    // Update is called once per frame
    void Update()
    {
        Ray ray = new Ray(origin, direction);
        
        if (Physics.Raycast(ray, out rayInfo, 200f, 1 ,QueryTriggerInteraction.Ignore))
        {
            switch (rayInfo.transform.tag)
            {
                case "Mirror":
                    if (reflection == null)
                    {
                        reflection = gameObject.AddComponent<LaserBeam>();
                        if (rayInfo.transform.gameObject.GetComponent<LineRenderer>() == null)
                        {
                            //lineRenderer = rayInfo.transform.gameObject.AddComponent<LineRenderer>();
                        }
                        else
                        {
                            //lineRenderer = rayInfo.transform.gameObject.GetComponent<LineRenderer>();
                        }
                            
                       // lineRenderer.SetPosition(0, origin);
                        //lineRenderer.SetPosition(1, rayInfo.point);
                        //lineRenderer.startWidth = 0.1f;
                        //lineRenderer.endWidth = 0.1f;
                    }
                    reflection.origin = rayInfo.point;
                    reflection.direction = Vector3.Reflect(direction, rayInfo.normal);
                    break;
                case "Target":
                    Debug.Log("Target hit!");
                    if (rayInfo.transform.gameObject.GetComponent<LineRenderer>() == null)
                    {
                        //lineRenderer = rayInfo.transform.gameObject.AddComponent<LineRenderer>();
                    }
                    else
                    {
                       // lineRenderer = rayInfo.transform.gameObject.GetComponent<LineRenderer>();
                    }
                   // lineRenderer.SetPosition(0, origin);
                   // lineRenderer.SetPosition(1, rayInfo.point);
                    //lineRenderer.startWidth = 0.1f;
                   // lineRenderer.endWidth = 0.1f;
                    break;
            }
            Debug.DrawLine(origin, rayInfo.point, Color.red);
            // line renderer
         
        }
        else
        {
            Destroy(reflection);
            Debug.DrawRay(origin, direction, Color.red);
        }

        // Timer run out destroy all, 
    }

    private void OnDrawGizmos()
    {
        Gizmos.DrawRay(origin, direction);
    }
}
*/
