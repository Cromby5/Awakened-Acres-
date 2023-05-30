using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Seeds : MonoBehaviour
{
    public GameObject grownCrop;
    public GameObject aiAgent;

    [SerializeField] private Land land;

    [SerializeField] private float timer = 5f;
    [SerializeField] private int aiLimit = 5;
    private bool isGrowing = false;

    [SerializeField] private GameObject state1, state2, state3;
    
    // Night before stuff, 
    [SerializeField] private GameObject cherryTree;
    [SerializeField] private bool isCherry = false;
    // Start is called before the first frame update
    void Start()
    {
   
    }

    // Update is called once per frame
    void Update()
    {
        if (land.landStatus == Land.LandStatus.Watered && !isGrowing)
        {
            land.SwitchLandStatus(Land.LandStatus.Growing);
            StartCoroutine(Grow());
        }
    }
    
    IEnumerator Grow()
    {
        isGrowing = true;
        yield return new WaitForSeconds(timer);
        // State 2
        state2.SetActive(true);
        state1.SetActive(false);
        yield return new WaitForSeconds(timer);
        // State 3
        state3.SetActive(true);
        state2.SetActive(false);
        yield return new WaitForSeconds(timer);
        int i = Random.Range(0, 3);
        if (i == 1 && aiAgent != null && !isCherry)
        {
            Debug.Log("AI Active");
            GameObject ai = Instantiate(aiAgent, transform.position, Quaternion.identity);
            GameManager.instance.crops.Add(ai);
            if (GameManager.instance.crops.Count > aiLimit)
            {
                GameObject temp = GameManager.instance.crops[0];
                GameManager.instance.crops.Remove(temp);
                Destroy(temp);
            }
        }
        else
        {
            if (isCherry)
            {
                cherryTree.SetActive(true);
                land.SwitchLandStatus(Land.LandStatus.Disabled);
                yield return null;
            }
            else
            {
                GameObject crop = Instantiate(grownCrop, transform.position, grownCrop.transform.rotation);
            }
        }
        
        if (!isCherry)
        {
            land.SwitchLandStatus(Land.LandStatus.Soil);
            gameObject.SetActive(false);
        }
        yield return null;
    }
    private void OnEnable()
    {
        isGrowing = false;
        state1.SetActive(true);
        state2.SetActive(false);
        state3.SetActive(false);
    }

    private void OnDisable()
    {
        StopCoroutine(Grow());
    }
}
