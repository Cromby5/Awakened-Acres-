using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System.Linq;

public class DataPersistManager : MonoBehaviour
{
    [Header("Storage Config")]
    [SerializeField] private string fileName;
    [SerializeField] private bool useEncryption;

    private GameData gameData;
    private List<IDataPersist> dataPersistList;
    private FileDataHandler dataHandler;
    public static DataPersistManager instance { get; private set;}

    private void Awake()
    {
        if (instance != null)
        {
            Debug.LogError("More than one DataPersistManager in scene!");
        }
        instance = this;
    }
   
    private void Start()
    {
        dataHandler = new FileDataHandler(Application.persistentDataPath, fileName, useEncryption);
        dataPersistList = FindAllDataPersistObjects();
        // TEMP, load game data on start
        LoadGame();
    }
    
    public void NewGame()
    {
        gameData = new GameData();
    }
    
    public void LoadGame()
    {
        gameData = dataHandler.Load();
        if (gameData == null)
        {
            Debug.Log("No game data to load! Defaulting to new game");
            NewGame();
        }
        // Passing data to other scripts
        foreach (IDataPersist dataPersist in dataPersistList)
        {
            dataPersist.LoadData(gameData);
        }

        Debug.Log("Game loaded!");
        Debug.Log("Position: " + gameData.playerTransformPos);
    }

    public void SaveGame()
    {
        // Passing data to other scripts, if you see this pop a null ref error it doesnt matter much since save system had to be cut as I dont have time 
        foreach (IDataPersist dataPersist in dataPersistList)
        {
            dataPersist.SaveData(gameData);
        }
        Debug.Log("Game Saved!");
        Debug.Log("Position: " + gameData.playerTransformPos);
        dataHandler.Save(gameData);
    }

    private void OnApplicationQuit()
    {
        SaveGame();
    }

    private List<IDataPersist> FindAllDataPersistObjects()
    {
        IEnumerable<IDataPersist> dataPersistObjects = FindObjectsOfType<MonoBehaviour>(true).OfType<IDataPersist>();
        return new List<IDataPersist>(dataPersistObjects);
    }

}
