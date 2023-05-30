using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;
public class AdditiveSceneLoadBuild : MonoBehaviour
{
    // Start is called before the first frame update
    void Start()
    {
        SceneManager.LoadSceneAsync("Farm", LoadSceneMode.Additive);
        SceneManager.LoadSceneAsync("Maze Caitlin 1", LoadSceneMode.Additive);
        SceneManager.LoadSceneAsync("Mirror Puzzle", LoadSceneMode.Additive);
        SceneManager.LoadSceneAsync("Witch Area", LoadSceneMode.Additive);
        SceneManager.LoadSceneAsync("BenTesting", LoadSceneMode.Additive);
        //SceneManager.LoadSceneAsync("Player", LoadSceneMode.Additive);
        Destroy(this);
    }

}

