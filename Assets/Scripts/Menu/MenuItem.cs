using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class MenuItem : MonoBehaviour
{
    public Color Hover;
    public Color Normal;
    public Image background;
    

    // Start is called before the first frame update
    void Start()
    {
        background.color = Normal;
    }

    public void Select()
    {
        background.color = Hover;
    }
    public void Deselect()
    {
        background.color = Normal;
    }

}
