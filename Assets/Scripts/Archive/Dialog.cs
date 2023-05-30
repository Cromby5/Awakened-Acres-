using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using TMPro;
public class Dialog : MonoBehaviour
{
    public TextMeshProUGUI textDisplay;
    public string[] sentences;
    private int index;
    public float typingSpeed;
    public float indexFix;
    public GameObject continueButton;
    public Image DialBox;
    private bool potion = false;
    private bool Chest = false;

    void Start()
    {
        textDisplay.gameObject.SetActive(false);
        continueButton.gameObject.SetActive(false);
        DialBox.enabled = false;
    }

    private void Update()
    {
        if(textDisplay.text == sentences[index])
        {
            continueButton.SetActive(true);
        }
        Debug.Log(indexFix);
    }

    IEnumerator Type()
    {
        foreach(char letter in sentences[index].ToCharArray())
        {
            textDisplay.text += letter;
            yield return new WaitForSeconds(typingSpeed);
        }
    }

    public void NextSentence()
    {
        continueButton.SetActive(false);
        if(index < indexFix)
        {
            index++;
            textDisplay.text = "";
            StartCoroutine(Type());
        }
        else 
        {
            index++;
            textDisplay.text = "";
            continueButton.SetActive(false);
            textDisplay.gameObject.SetActive(false);
            continueButton.gameObject.SetActive(false);
            DialBox.enabled = false;
            GameObject.Find("Player").GetComponent<PlayerMovement>().enabled = true;
            GameObject.Find("Idle Breathing").GetComponent<Animator>().enabled = true;
        }
    }

    private void OnCollisionEnter(Collision collision)
    {
        if (collision.gameObject.CompareTag("dialogue"))
        {
            float.TryParse(collision.gameObject.name, out indexFix);
            Destroy(collision.gameObject);
            textDisplay.gameObject.SetActive(true);
            continueButton.gameObject.SetActive(true);
            DialBox.enabled = true;
            StartCoroutine(Type());
            GameObject.Find("Player").GetComponent<PlayerMovement>().enabled = false;
            GameObject.Find("Idle Breathing").GetComponent<Animator>().enabled = false;
        }

        if (collision.gameObject.name == "Chest" && Chest == false)
        {
            index = 2;
            indexFix = 2;
            textDisplay.gameObject.SetActive(true);
            continueButton.gameObject.SetActive(true);
            DialBox.enabled = true;
            StartCoroutine(Type());
            GameObject.Find("Player").GetComponent<PlayerMovement>().enabled = false;
            GameObject.Find("Idle Breathing").GetComponent<Animator>().enabled = false;
        }

        if (collision.gameObject.name.Contains("Potion") && potion == false)
        {
            potion = true;
            index = 3;
            indexFix = 4;
            textDisplay.gameObject.SetActive(true);
            continueButton.gameObject.SetActive(true);
            DialBox.enabled = true;
            StartCoroutine(Type());
            GameObject.Find("Player").GetComponent<PlayerMovement>().enabled = false;
            GameObject.Find("Idle Breathing").GetComponent<Animator>().enabled = false;
        }
    }
}
