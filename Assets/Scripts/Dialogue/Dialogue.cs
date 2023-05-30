using Newtonsoft.Json;
using System;
using System.Collections;
using System.Collections.Generic;
using System.IO;
using UnityEngine;

[System.Serializable]
public class Dialogue
{
   // public int id;
    //public image sprite
    
    public string speakerName;
    [TextArea(3, 10)]
    public string[] sentences;

    public Sprite sprite;

    /*
    public void ReadFile()
    {
        using (StreamReader r = new StreamReader(Application.streamingAssetsPath + "/" + "Dialogue" + ".json"))
        {
            string json = r.ReadToEnd();

            Dialogue items = JsonConvert.DeserializeObject<Dialogue>(json);
            
            speakerName = items.speakerName;
            sentences = items.sentences;
        }
    }
    */
}
