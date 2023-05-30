using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class HealthSystem : MonoBehaviour, IDataPersist
{
    [SerializeField] private int maxHealth;
    private int currentHealth;

    [SerializeField] private HealthBar myHealthBar;

    [SerializeField] private float invincibilityTime;
    private float savedITime;

    void Start()
    {
        currentHealth = maxHealth; // Our current health is set to the max we can have
        savedITime = invincibilityTime;
        myHealthBar.DrawHealth(currentHealth,maxHealth); // Show health by dividing current by max to get a fraction for the show health function
    }
    
    void Update()
    {
        if (invincibilityTime > 0)
        {
            invincibilityTime -= Time.deltaTime;
        }
    }
    
    public void TakeDamage(int damageAmount)
    {
        if (currentHealth > 0 && invincibilityTime <= 0)
        {
            currentHealth -= damageAmount;
            GameManager.AudioManager.Play("Damage Taken");
            myHealthBar.DrawHealth(currentHealth, maxHealth); 
            if (currentHealth <= 0)
            {
                // Die
                transform.position = GameManager.Spawn.position;
                currentHealth = maxHealth;
                myHealthBar.DrawHealth(currentHealth, maxHealth);
                
                RenderSettings.skybox = GameManager.instance.skybox_a;
                DynamicGI.UpdateEnvironment();
                RenderSettings.fog = false;
                GameManager.switchSky.isDay = true;
                GameManager.switchSky.blockcade.SetActive(false);
                GameManager.switchSky.blockcade2.SetActive(true);
            }
            invincibilityTime = savedITime;
        }
    }
    public void Heal(int healAmount)
    {
        if (currentHealth < maxHealth)
        {
            currentHealth += healAmount;
            if (currentHealth > maxHealth)
            {
                currentHealth = maxHealth;
            }
            myHealthBar.DrawHealth(currentHealth, maxHealth);
        }
    }
    
    public void LoadData(GameData data)
    {
        currentHealth = data.currentHealth;
        maxHealth = data.maxHealth;
        myHealthBar.DrawHealth(currentHealth, maxHealth);
    }
    public void SaveData(GameData data)
    {
        data.currentHealth = currentHealth;
        data.maxHealth = maxHealth;
    }
}
