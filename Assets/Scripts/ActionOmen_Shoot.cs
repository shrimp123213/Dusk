using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ActionOmen_Shoot : MonoBehaviour
{
    public new ParticleSystem[] particleSystem = new ParticleSystem[4];

    public float speed;

    void Start()
    {
        particleSystem[0] = GetComponent<ParticleSystem>();
        particleSystem[1] = transform.GetChild(0).GetComponent<ParticleSystem>();
        particleSystem[2] = transform.GetChild(1).GetComponent<ParticleSystem>();
        particleSystem[3] = transform.GetChild(2).GetComponent<ParticleSystem>();
    }

    private void Update()
    {
        foreach(var particle in particleSystem)
        {
            if (particle != null)
            {
                var velocityOverLifetime = particle.velocityOverLifetime;
                velocityOverLifetime.radialMultiplier = Mathf.Clamp(velocityOverLifetime.radialMultiplier + velocityOverLifetime.radialMultiplier * Time.deltaTime * speed, -200f, 0f);
            }
        }
    }


}
