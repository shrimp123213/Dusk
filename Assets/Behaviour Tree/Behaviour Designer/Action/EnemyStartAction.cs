using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using BehaviorDesigner.Runtime;
using BehaviorDesigner.Runtime.Tasks;

public class EnemyStartAction : EnemyActionBase
{
    public SharedTransform Target;
    
    public ActionBaseObj Action;
    
    //public string ReverseAnimationName;
   
    private bool Fail;
    
    public override void OnStart()
    {
        this.Fail=(this.SelfCharacter.Value.Airbrone || this.SelfCharacter.Value.isDead);
        if(!this.Fail)
            this.SelfCharacter.Value.StartAction(this.Action);
    }

    public override TaskStatus OnUpdate()
    {
        if (this.Fail)
        {
            return TaskStatus.Failure;
        }
        if (this.SelfCharacter.Value.isActing)
        {
            return TaskStatus.Running;
        }
        /*if (this.SelfCharacter.Value.NowAction == null && ReverseAnimationName != "")
        {
            Animator Ani =this.transform.GetComponentInChildren<Animator>();
            Ani.Play(ReverseAnimationName);
            if(Ani.GetCurrentAnimatorStateInfo(0).normalizedTime >= 1.0f)
                return TaskStatus.Success;
        }*/
        return TaskStatus.Success;
    }
}
