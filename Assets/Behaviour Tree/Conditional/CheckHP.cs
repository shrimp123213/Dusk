using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using BehaviorDesigner.Runtime;
using BehaviorDesigner.Runtime.Tasks;

public class CheckHP : EnemyConditionalBase
{
    public float CheckHPValue;
    private float currentHealth;


    public override void OnStart()
    {
        currentHealth = this.SelfCharacter.Value.Health;
    }

    public override TaskStatus OnUpdate()
    {
        if (currentHealth <= CheckHPValue)
        {
            return TaskStatus.Success;
        }
        return TaskStatus.Failure;
    }
}
