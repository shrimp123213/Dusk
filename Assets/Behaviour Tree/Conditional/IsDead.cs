using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using BehaviorDesigner.Runtime;
using BehaviorDesigner.Runtime.Tasks;

public class IsDead : EnemyConditionalBase
{
    public override TaskStatus OnUpdate()
    {
        if(this.SelfCharacter.Value.isDead)
        {
            return TaskStatus.Success;
        }
        return TaskStatus.Failure;
    }
}
