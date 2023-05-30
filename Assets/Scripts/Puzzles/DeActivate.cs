using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class DeActivate : MonoBehaviour
{
    [SerializeField] private GameObject blockcade;
    
    [SerializeField] private SwitchSky sky;

   // Start is called before the first frame update
   private void OnTriggerEnter(Collider other)
    {
        blockcade.SetActive(false);
        sky.Daytime();
        sky.blockcade2.SetActive(false);
    }
}
