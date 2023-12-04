using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using BehaviorDesigner.Runtime;
using BehaviorDesigner.Runtime.Tasks;

public class EnemyFaceTo : EnemyActionBase
{
    public SharedTransform Target;
    public int Facing = 1;
    
    public override void OnStart()
    {
        Facing = (this.Target.Value.transform.position.x > this.transform.position.x) ? 1 : -1;
        this.SelfCharacter.Value.Facing = Facing;
    }
    
    public override void OnEnd()
    {
        base.OnEnd();
    }

    public override TaskStatus OnUpdate()
    {
        if(this.SelfCharacter.Value.Facing == Facing)
            return TaskStatus.Success;

        return TaskStatus.Running;
    }
}
