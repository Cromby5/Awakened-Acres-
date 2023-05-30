using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using UnityEngine.UI.Extensions;

public class AbilityBar : MonoBehaviour
{
    [SerializeField] private Slider slider;
    [SerializeField] private Image redSlider;
    //[SerializeField] public RadialSlider radSlider;
    
    // For ability damage
    [SerializeField] private float invincibilityTime;
    [SerializeField] private ParticleSystem damageParticles;
    private float savedITime;
    private bool isDecreasing = false;
    
    // Start is called before the first frame update
    void Start()
    {
        savedITime = invincibilityTime;
    }

    // Update is called once per frame
    void Update()
    {
        if (invincibilityTime > 0)
        {
            invincibilityTime -= Time.deltaTime;
        }
    }

    public void AbilityBarIncrease(int amount)
    {
        // Increase ability bar
        slider.value += amount;
        redSlider.fillAmount = slider.value / 100;
    }

    public void AbilityBarDecrease(int amount)
    {
        // Decrease ability bar
        slider.value -= amount;
        if (!isDecreasing)
        {
            StartCoroutine(AbilityBarDecreaseOverTime());
        }
    }
    // Main difference is the effects and check to see if time has passed since last "damage" taken
    public void AbilityBarDamage(int amount)
    {
        if (invincibilityTime > 0)
            return;
        GameManager.AudioManager.Play("Damage Taken");
        damageParticles.Play();
        AbilityBarDecrease(amount);
        invincibilityTime = savedITime;
    }
    
    IEnumerator AbilityBarDecreaseOverTime()
    {
        float t = 1;
        isDecreasing = true;
        yield return new WaitForSeconds(0.5f);
        while (t >= 0)
        {
            t -= 0.1f;
            yield return new WaitForSeconds(0.1f);
            redSlider.fillAmount = Mathf.Lerp(slider.value / 100, redSlider.fillAmount, t);
        }
        isDecreasing = false;
        yield break;
    }

    public float GetSliderValue()
    {
        return slider.value;
    }
}
