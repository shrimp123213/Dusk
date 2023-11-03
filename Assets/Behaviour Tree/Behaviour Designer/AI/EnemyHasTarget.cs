using System.Collections;
using System.Collections.Generic;
using BehaviorDesigner.Runtime;
using UnityEngine;
using BehaviorDesigner.Runtime.Tasks;

public class EnemyHasTarget : EnemyConditionalBase
{
    public SharedTransform Target;

    public override TaskStatus OnUpdate()
    {
        if(this.Target.Value== null)
        {
            return TaskStatus.Failure;
        }
        return TaskStatus.Success;
    }
}
