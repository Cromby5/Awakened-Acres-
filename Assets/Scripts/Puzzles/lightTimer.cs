using System.Collections;
using System.Collections.Generic;
using TMPro;
using UnityEngine;
using UnityEngine.UI;

// I want to rename this but everytime I try it reverts which is really annoying since it breaks each time
public class lightTimer : MonoBehaviour
{
    public enum LightStage
    {
        Stage1,
        Stage2,
        Stage3,
        Off,
    }
    
    private LightStage currentStage = LightStage.Stage1;
    
    public float timeLeft = 10.0f;
    [SerializeField] private float timePerStage;
    [SerializeField] private float timeLastStage = 3f;
    public bool timerIsRunning = false;
    public bool isDark = false;

    [SerializeField] private GameObject panel;
    [SerializeField] private TextMeshProUGUI timerTxt;
    [SerializeField] private Slider lightSlide;
    [SerializeField] private Light lighta;

    [Header("Light Settings")]
    [SerializeField] private float flickTime;
    [SerializeField] private float normalIntensity;
    [SerializeField] private float dimIntensity;
    [Header("Range Settings")]
    [SerializeField] private float stage1Range;
    [SerializeField] private float stage2Range;
    [SerializeField] private float stage3Range;



    private static lightTimer instance;

    private void Awake()
    {
        instance = this;
        lighta.intensity = normalIntensity;
    }
    
    public static lightTimer GetLightTimer()
    {
        return instance;
    }
    
    void Update()
    {
        if (timerIsRunning)
        {
            if (timeLeft > 0)
            {
                timeLeft -= Time.deltaTime;
                //timerTxt.text = timeLeft.ToString("0");
                lightSlide.value = timeLeft;
            }
            else
            {
                timeLeft = 0;
                SwitchStage(currentStage + 1);
            }
        }
        else
        {
            gameObject.SetActive(false);
        }

        switch (currentStage)
        {
            case LightStage.Stage1:
                lighta.spotAngle = Mathf.Lerp(stage2Range, stage1Range, timeLeft);
                break;
            case LightStage.Stage2:
                lighta.spotAngle = Mathf.Lerp(stage3Range, stage2Range, timeLeft);
                break;
            case LightStage.Stage3:

                break;
            case LightStage.Off:
                gameObject.SetActive(false);
                break;
        }
        
    }
    public void StartTimer()
    {
        timerIsRunning = true;
        timeLeft = timePerStage;
        panel.SetActive(true);
        SwitchStage(LightStage.Stage1);
    }

    public void SwitchStage(LightStage stage)
    {
        currentStage = stage;
        timeLeft = timePerStage;
        switch (stage)
        {
            case LightStage.Stage1:
                lighta.spotAngle = stage1Range;
                lighta.intensity = normalIntensity;
                lightSlide.maxValue = timePerStage;
                break;
            case LightStage.Stage2:
                //lighta.spotAngle = stage2Range;
                lighta.intensity = normalIntensity;
                lightSlide.maxValue = timePerStage;
                break;
            case LightStage.Stage3:
                //lighta.spotAngle = stage3Range;
                StartCoroutine(FlickerLight());
                lightSlide.maxValue = timeLastStage;
                break;
            case LightStage.Off:
                gameObject.SetActive(false);
                break;
        }
    }
    IEnumerator FlickerLight()
    {
        yield return new WaitForSeconds(0.1f);
        timeLeft = timeLastStage;
        while (currentStage == LightStage.Stage3 && timeLeft > 0)
        {
            lighta.intensity = dimIntensity;
            yield return new WaitForSeconds(flickTime);
            lighta.intensity = normalIntensity;
            yield return new WaitForSeconds(flickTime);
        }
        yield break;
    }
    
    private void OnDisable()
    {
        panel.SetActive(false);
        timerIsRunning = false;
        timeLeft = timePerStage;
    }
}
