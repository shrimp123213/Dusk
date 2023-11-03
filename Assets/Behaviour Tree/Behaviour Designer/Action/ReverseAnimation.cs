using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using BehaviorDesigner.Runtime;
using BehaviorDesigner.Runtime.Tasks;

public class ReverseAnimation : EnemyActionBase
{
    public string ReverseAnimationName;

    public override TaskStatus OnUpdate()
    {
        if (!(this.SelfCharacter.Value.isActing))
        {
            Animator Ani =this.transform.GetComponentInChildren<Animator>();
            Ani.Play(ReverseAnimationName);
            if(Ani.GetCurrentAnimatorStateInfo(0).normalizedTime >= 1.0f)
                return TaskStatus.Success;
        }
        
        return TaskStatus.Running;
    }
}
