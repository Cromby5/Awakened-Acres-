using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class JournelEnable : MonoBehaviour
{
    [SerializeField] private GamepadCursor gamepadCursor;
    [SerializeField] private Image book;

    [SerializeField] private List<GameObject> pages = new List<GameObject>();
    [SerializeField] private int currentPage = 0;
    [SerializeField] private Button inv;

    private void Start()
    {
        GameManager.je = this;
    }
    private void OnEnable()
    {
        //gamepadCursor.cursorTransform.gameObject.SetActive(true);
        book.gameObject.SetActive(false);
        GameManager.LevelManager.ActiveUI(false);
        inv.Select();
    }
    
    private void OnDisable()
    {
        //gamepadCursor.cursorTransform.gameObject.SetActive(false);
        book.gameObject.SetActive(true);
        GameManager.LevelManager.ActiveUI(true);
    }

    public void ChangePage(int page)
    {
        pages[currentPage].SetActive(false);
        pages[page].SetActive(true);
        currentPage = page;
    }

    public void NextPage()
    {
        if (currentPage < pages.Count - 1)
        {
            ChangePage(currentPage + 1);
        }
    }
    public void PreviousPage()
    {
        if (currentPage > 0)
        {
            ChangePage(currentPage - 1);
        }
    }

}
