using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public interface IDataPersist
{
    void LoadData(GameData data);
    
    void SaveData(GameData data);

}
