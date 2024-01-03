using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ActionOmen : MonoBehaviour
{
    public GameObject OmenSpawnPointWithTarget;
    public float liftTime = 1f;
    
    private bool hasTarget = false;

    public new ParticleSystem particleSystem;

    void Start()
    {
        particleSystem = GetComponent<ParticleSystem>();

        Destroy(gameObject, liftTime);
    }
    
    void FixedUpdate()
    {
        if (hasTarget)
        {
            var particles = new ParticleSystem.Particle[particleSystem.main.maxParticles];
            var currentAmount = particleSystem.GetParticles(particles);

            // Change only the particles that are alive
            for (int i = 0; i < currentAmount; i++) 
            {
                particles[i].position = OmenSpawnPointWithTarget.transform.position;
            }

            // Apply the particle changes to the Particle System
            particleSystem.SetParticles(particles, currentAmount);
        }
    }
    
    public void SetTarget(GameObject target)
    {
        OmenSpawnPointWithTarget = target;
        hasTarget = true;
    }
}
