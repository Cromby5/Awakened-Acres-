using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.AI;

public class NPCMove : MonoBehaviour
{
    NavMeshAgent agent;

    // Point to go to when not actively tracking the player
    public Vector3 roamPath;
    public float roamDistance;
    [SerializeField] private float DistanceToRecalculate; //The distance the enemy will recalculate the path
    private bool hasRoamPath;

    [SerializeField] private Animator animator;

    [SerializeField] private float timeToIdle;
    [SerializeField] private float currentTime;

    // List of points to patrol, if empty, the enemy will roam around the nav mesh at random points instead
    public List<Transform> patrolPoints = new List<Transform>();
    public List<TextAsset> patrolDialogue = new List<TextAsset>();
    public int currentPatrolPoint = -1;
    
    
    private enum NPCState
    {
        Idle,
        Roaming,
        Locked,
        Patrol,
    }

    [SerializeField] private NPCState currentState;
    [SerializeField] private NPCState lastState;

    void Start()
    {
        hasRoamPath = false;
        // Get the nav mesh agent
        agent = GetComponent<NavMeshAgent>();

        if (currentState == NPCState.Patrol)
        {
            Patrol();
        }
    }

    private void FixedUpdate()
    {
        // Enemy will start to walk around the nav mesh at random points
        switch (currentState)
        {
            case NPCState.Idle:
                currentTime += Time.deltaTime;
                if (currentTime >= timeToIdle)
                {
                    currentState = NPCState.Roaming;
                    currentTime = 0;
                }
                break;
            case NPCState.Roaming:
                Roam();
                break;
            case NPCState.Locked:
                agent.SetDestination(transform.position);
                break;

            case NPCState.Patrol:
              
                break;
        }
        if (animator != null)
        {
            if (agent.velocity.magnitude > 0)
            {
                animator.SetBool("isWalking", true);
            }
            else
            {
                animator.SetBool("isWalking", false);
            }
        }
    }

    void Roam()
    {
        // If the enemy does not have a destination to roam to get a random point inside a sphere and check with the nav mesh that it is an area the enemy can get to
        if (!hasRoamPath)
        {
            if (Random.Range(0, 100) < 10)
            {
                Vector3 randomPoint = transform.position + Random.insideUnitSphere * roamDistance;
                NavMeshHit hit;
                NavMesh.SamplePosition(randomPoint, out hit, roamDistance, NavMesh.AllAreas); // Finds the nearest point on the navmesh specificed with the range
                roamPath = hit.position;
                hasRoamPath = true;
            }
            else
            {
                currentState = NPCState.Idle;
            }
        }
        else
        {
            // Go towards the destination
            agent.SetDestination(roamPath);
            Vector3 distanceToDestination = transform.position - roamPath;
            // If our distance to the destination is less than x set roam path to false to create a new point for the enemy to go towards
            if (distanceToDestination.magnitude < DistanceToRecalculate)
            {
                hasRoamPath = false;
            }
            // Fixes a bug where the agent would get stuck in a loop of going to the same point, staying in place forever
            if (distanceToDestination.x == float.PositiveInfinity || distanceToDestination.x == float.NegativeInfinity)
            {
                hasRoamPath = false;
            }
        }
    }

    public void Patrol()
    {
        // Only exists for the carrot really, not the best solution at all. Called with dialogue
        currentPatrolPoint++;
        if (currentPatrolPoint >= patrolPoints.Count)
        {
            currentState = NPCState.Idle;
            return;
        }
        agent.SetDestination(patrolPoints[currentPatrolPoint].position);
    }

    public void SetState(int state)
    {
        lastState = currentState;
        currentState = (NPCState)state;
    }

    public int GetState()
    {
        return (int)currentState;
    }
    public int GetLastState()
    {
        return (int)lastState;
    }
    public TextAsset GetDialogue()
    {
        return patrolDialogue[currentPatrolPoint];
    }

}

