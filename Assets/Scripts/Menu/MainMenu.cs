using System.Collections;
using System.Collections.Generic;
using TMPro;
using UnityEngine;
using UnityEngine.SceneManagement;
using UnityEngine.UI;

public class MainMenu : MonoBehaviour
{
    public int screenMode = 0;
    private bool isFullScreen;

    public TMP_Dropdown resDropdown;
    Resolution[] resolutions;

    public GameObject mainMenu;
    [Header("Loading Screen")]
    public GameObject loadingScreen;
    public Image loadBar;
    List<AsyncOperation> scenesToLoad = new List<AsyncOperation>();
    
    // Caught rewatching brackeys settings tutorial at 3am
    private void Start()
    { 
        if (resDropdown == null)
        return;
            resolutions = Screen.resolutions;
            resDropdown.ClearOptions();
            List<string> options = new List<string>();

            int currentResIndex = 0;
            for (int i = 0; i < resolutions.Length; i++)
            {
                string option = resolutions[i].width + " x " + resolutions[i].height + " @ " + resolutions[i].refreshRate + "hz";
                options.Add(option); // Add to list
                if (resolutions[i].width == Screen.currentResolution.width && resolutions[i].height == Screen.currentResolution.height && resolutions[i].refreshRate == Screen.currentResolution.refreshRate) // Check if current resolution
                {
                    currentResIndex = i;
                }
            }

            resDropdown.AddOptions(options); // Add list to dropdown
            resDropdown.value = currentResIndex; // Set current resolution
            resDropdown.RefreshShownValue(); // Refresh dropdown

    }
    public void PlayGame()
    {
        // The intentional way of additive scenes working for me and the build
        mainMenu.SetActive(false);
        loadingScreen.SetActive(true);
        scenesToLoad.Add(SceneManager.LoadSceneAsync("Player"));
        scenesToLoad.Add(SceneManager.LoadSceneAsync("Farm", LoadSceneMode.Additive));
        scenesToLoad.Add(SceneManager.LoadSceneAsync("Maze Caitlin 1", LoadSceneMode.Additive));
        scenesToLoad.Add(SceneManager.LoadSceneAsync("Mirror Puzzle", LoadSceneMode.Additive));
        scenesToLoad.Add(SceneManager.LoadSceneAsync("Witch Area", LoadSceneMode.Additive));
        //scenesToLoad.Add(SceneManager.LoadSceneAsync("BenTesting", LoadSceneMode.Additive));
        StartCoroutine(LoadScenes());
    }
    
    public void PlayIntro()
    {
        SceneManager.LoadScene("StartSequence");
    }

   public void ReturnMainMenu()
    {
        SceneManager.LoadScene("Menu");
    }

    public void PlayOneSceneGame()
    {
        // panic mode 3.0
        SceneManager.LoadScene("Last1ScenePanic");
    }

    IEnumerator LoadScenes()
    {
        float totalProgress = 0;
        for (int i = 0; i < scenesToLoad.Count; i++)
        {
            while (!scenesToLoad[i].isDone)
            {
                totalProgress += scenesToLoad[i].progress;
                loadBar.fillAmount = totalProgress / scenesToLoad.Count;
                yield return null;
            }
        }
    }

    public void QuitGame()
    {
        Application.Quit();
    }

    public void SetScreenMode(int mode)
    {
        screenMode = mode;
        switch (screenMode)
        {
            case 0:
                Screen.fullScreen = true;
                Screen.fullScreenMode = FullScreenMode.ExclusiveFullScreen;
                break;
            case 1:
                Screen.fullScreenMode = FullScreenMode.FullScreenWindow;
                break;
            case 2:
                Screen.fullScreen = false;
                Screen.fullScreenMode = FullScreenMode.Windowed;
                break;
        }
        isFullScreen = Screen.fullScreen;
    }

    public void SetResolution(int resIndex)
    {
        Screen.SetResolution(resolutions[resIndex].width, resolutions[resIndex].height, Screen.fullScreen);
    }
}

