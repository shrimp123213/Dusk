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
        EqualTo
    }

    public OperatorType operatorType;
    
    public float SocialDistance = 2f;
    
    private float _socialDistance;

    public override void OnStart()
    {
        _socialDistance = SocialDistance;
    }
    
    public override TaskStatus OnUpdate()
    {
        //_socialDistance *= this.SelfCharacter.Value.transform.localScale.x;
        if (this.Target.IsShared)
        {
            switch (operatorType)
            {
                case OperatorType.LessThan:
                    if (Vector2.Distance(this.Target.Value.transform.position, this.transform.position) < this._socialDistance)
                    {
                        //Debug.Log("Less:"+SocialDistance);
                        return TaskStatus.Success;
                    }
                    break;
                case OperatorType.GreaterThan:
                    if (Vector2.Distance(this.Target.Value.transform.position, this.transform.position) > this._socialDistance)
                    {
                        //Debug.Log("Greater:"+SocialDistance);
                        return TaskStatus.Success;
                    }
                    break;
                case OperatorType.EqualTo:
                    if(Vector2.Distance(this.Target.Value.transform.position, this.transform.position) > this._socialDistance - 1f &&
                       Vector2.Distance(this.Target.Value.transform.position, this.transform.position) < this._socialDistance + 1f)
                    {
                        //Debug.Log("Equal:"+SocialDistance);
                        return TaskStatus.Success;
                    }
                    break;
                
            }
        }
        return TaskStatus.Failure;
    }
}
