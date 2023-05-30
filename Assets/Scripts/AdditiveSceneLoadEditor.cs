#if UNITY_EDITOR
using System.Collections;
using System.Collections.Generic;
using UnityEditor;
using UnityEditor.SceneManagement;

using UnityEngine;
using UnityEngine.SceneManagement;

[ExecuteInEditMode]
public class AdditiveSceneLoadEditor : MonoBehaviour
{
    private void Awake()
    {
        if (!EditorApplication.isPlaying)
        {
            EditorSceneManager.OpenScene("Assets/Scenes/Farm.unity", OpenSceneMode.Additive);
            EditorSceneManager.OpenScene("Assets/Scenes/Maze Caitlin 1.unity", OpenSceneMode.Additive);
            EditorSceneManager.OpenScene("Assets/Scenes/Mirror Puzzle.unity", OpenSceneMode.Additive);
            EditorSceneManager.OpenScene("Assets/Scenes/Witch Area.unity", OpenSceneMode.Additive);
            // These are for playing around in the editor indivdually 
            EditorSceneManager.OpenScene("Assets/Scenes/AdditiveTesting/BenTesting.unity", OpenSceneMode.Additive);
            // EditorSceneManager.OpenScene("Assets/Scenes/Map.unity", OpenSceneMode.Additive);
        }
    }

    private void Start()
    {
        EditorSceneManager.SetActiveScene(SceneManager.GetSceneByName("Player"));
    }
    void Save()
    {
        EditorSceneManager.SaveOpenScenes();
    }
}
#endif
