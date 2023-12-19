using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using BehaviorDesigner.Runtime;
using BehaviorDesigner.Runtime.Tasks;

public class CheckDistance : EnemyConditionalBase
{
    public SharedTransform Target;
    
    public enum OperatorType
    {
        LessThan,
        GreaterThan,

    }

    public OperatorType operatorType;
    
    public float SocialDistance = 2f;

    public override TaskStatus OnUpdate()
    {
        if (this.Target.IsShared)
        {
            switch (operatorType)
            {
                case OperatorType.LessThan:
                    if (Vector2.Distance(this.Target.Value.transform.position, this.transform.position) < this.SocialDistance)
                    {
                        //Debug.Log("Less:"+SocialDistance);
                        return TaskStatus.Success;
                    }
                    break;
                case OperatorType.GreaterThan:
                    if (Vector2.Distance(this.Target.Value.transform.position, this.transform.position) > this.SocialDistance)
                    {
                        //Debug.Log("Greater:"+SocialDistance);
                        return TaskStatus.Success;
                    }
                    break;
                
            }
        }
        return TaskStatus.Failure;
    }
}
