using System.Collections;
using UnityEngine;
using Cinemachine;

public class LaserTarget : MonoBehaviour
{
    
    [SerializeField] private GameObject[] targetsToActivate;

    [SerializeField] private CinemachineVirtualCamera vCam;
    [SerializeField] private float timeToShowCam = 3f;

    [SerializeField] private bool requireKey;

    public void ActivateTargets()
    {
        GameManager.cinemachineCamera.ChangeCameraAndLock(vCam);
        StartCoroutine(Wait());
    }

    IEnumerator Wait()
    {
        yield return new WaitForSeconds(1f);
        foreach (GameObject target in targetsToActivate)
        {
            switch (target.name)
            {
                case "GatePortalIris":
                    target.GetComponent<Animator>().SetBool("isOpen", true);
                    break;
                case "Chest":
                    target.GetComponent<Chest>().OpenChest();
                    break;
                case "ChilliCauldron":
                    if (target != null)
                    {
                        GameManager.dialogueReferences.dialogueTrigger[2].TriggerDialogue();
                        Destroy(target);
                    }
                    break;
            }
            
            switch (target.tag)
            {
                case "Portal":
                    target.GetComponent<BoxCollider>().enabled = true;
                    break;

            }
        }
        yield return new WaitForSeconds(timeToShowCam);
        GameManager.cinemachineCamera.ResetCam();
        vCam.enabled = false;
        Destroy(gameObject);

    }

}
