using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class Land : MonoBehaviour, IDataPersist
{
    public enum LandStatus
    {
        Raw, Soil, Growing, Watered, Disabled
    }
    [SerializeField] private string id;

    [ContextMenu("Generate guid for id")]
    private void GenerateGuid()
    {
        id = System.Guid.NewGuid().ToString();
    }

    public LandStatus landStatus;

    public Material rawMat, soilMat, farmlandMat, wateredMat;
    Renderer rendererz;

    //The selection gameobject to enable when the player is selecting the land
    public GameObject select;

    [SerializeField] private GameObject carrotSeedling;
    [SerializeField] private GameObject chilliSeedling;
    [SerializeField] private bool canPlantCherry = false;
    [SerializeField] private GameObject cherrySeedling;

    public GameObject soil;

    // Bad fix
    public int toolShow;

    // Real context action?
    [SerializeField] private Image image;
    [SerializeField] private Sprite[] contextImages;


    // Start is called before the first frame update
    void Start()
    {
        //Get the renderer component
        rendererz = GetComponent<Renderer>();

        //Set the land to raw by default
        SwitchLandStatus(landStatus);

        //Deselect the land by default
        Select(false);
        
        Seedling(false);
        ChilliSeedling(false);
        CherrySeedling(false);
    }

    public void LoadData(GameData data)
    {
        

    }

    public void SaveData(GameData data)
    {
       
    }

    public void SwitchLandStatus(LandStatus statusToSwitch)
    {
        //Set land status accordingly
        landStatus = statusToSwitch;

        Material materialToSwitch = rawMat;

        //Decide what material to switch to
        switch (statusToSwitch)
        {
            case LandStatus.Raw:
                //Switch to the soil material
                materialToSwitch = rawMat;
                soil.SetActive(false);
                toolShow = 1;
                image.sprite = contextImages[0];
                break;
            case LandStatus.Soil:
                //Switch to the soil material
                materialToSwitch = soilMat;
                soil.SetActive(true);
                soil.GetComponent<Renderer>().material = materialToSwitch;
                toolShow = 2;
                image.sprite = contextImages[2];
                break;
            case LandStatus.Growing:
                toolShow = 0;
                image.sprite = contextImages[0];
                GameManager.dialogueReferences.dialogueTrigger[0].TriggerDialogue();
                break;
            case LandStatus.Watered:
                //Switch to watered material
                materialToSwitch = wateredMat;
                soil.GetComponent<Renderer>().material = materialToSwitch;
                toolShow = 0;
                image.sprite = contextImages[0];
                return;
            case LandStatus.Disabled:
                soil.SetActive(false);
                toolShow = 0;
                image.sprite = contextImages[0];
                break;
        }

        //Get the renderer to apply the changes
        rendererz.material = materialToSwitch;
    }

    public void Select(bool toggle)
    {
        select.SetActive(toggle);
        image.enabled = toggle;
    }

    public void Seedling(bool toggle)
    {
        carrotSeedling.SetActive(toggle);
    }
    public void ChilliSeedling(bool toggle)
    {
        chilliSeedling.SetActive(toggle);
    }
    public void CherrySeedling(bool toggle)
    {
        cherrySeedling.SetActive(toggle);
    }


    //When the player presses the interact button while selecting this land
    public bool Interact()
    {
        if (landStatus == LandStatus.Disabled)
            return false;
        
        // If the tool is a hoe
        /*
        if (landStatus == LandStatus.Raw || landStatus == LandStatus.Watered)
        {
            GameManager.AudioManager.Play("Farming Spell");
            //Switch the land status to soil
            SwitchLandStatus(LandStatus.Soil);
            return true;
        }
        */
        // If the tool is a watering can
        else if (landStatus == LandStatus.Soil)
        {
            GameManager.AudioManager.Play("Farming Spell");
            //Switch the land status to watered
            SwitchLandStatus(LandStatus.Watered);
            return true;
        }
        return false;
    }
    public bool InvInteract(string name)
    {
        if (chilliSeedling.activeSelf)
            return false;
        if (carrotSeedling.activeSelf)
            return false;
        if (cherrySeedling.activeSelf)
            return false;
        if (landStatus == LandStatus.Growing)
            return false;
        if (landStatus == LandStatus.Disabled)
            return false;

        // If the tool is a seed
        if (name == "CarrotSeed" && landStatus == LandStatus.Soil || name == "CarrotSeed" && landStatus == LandStatus.Watered)
        {
            Seedling(true);
            return true;
        }
        else if (name == "ChilliSeed" && landStatus == LandStatus.Soil || name == "ChilliSeed" && landStatus == LandStatus.Watered)
        {
            ChilliSeedling(true);
            return true;
        }
        else if (name == "CherrySeed" && landStatus == LandStatus.Soil && canPlantCherry || name == "CherrySeed" && landStatus == LandStatus.Watered && canPlantCherry)
        {
            CherrySeedling(true);
            return true;
        }

        return false;
    }
}