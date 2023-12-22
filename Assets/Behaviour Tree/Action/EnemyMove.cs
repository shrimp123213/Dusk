using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using BehaviorDesigner.Runtime;
using BehaviorDesigner.Runtime.Tasks;

public class EnemyMove : EnemyActionBase
{
    public SharedTransform Target;
    
    public float SocialDistance = 2f;
    public float MoveTime;
    
    public string AnimationName;
    
    private float timePassed;
    private float speed;
    private int way = 1;
    
    public override void OnStart()
    {
        this.timePassed = 0f;
        this.way=(Random.Range(0, 100) > 50) ? 1 : -1 ;
        this.speed = this.Target.Value == null ? Random.Range(0.3f, 0.5f) : 1f;
    }
    
    public override void OnEnd()
    {
        this.SelfCharacter.Value.Xinput = 0f;
    }

    public override TaskStatus OnUpdate()
    {
        Animator Ani =this.transform.GetComponentInChildren<Animator>();
        
        if (AnimationName != null)
        {
            //Ani.Rebind();
            Ani.Play(AnimationName);
            //Ani.Update(0f);
        }
        
        if (this.Target.IsShared)
        {
            if (Vector2.Distance(this.Target.Value.transform.position, this.transform.position) < this.SocialDistance &&
                Vector3Utility.IsFacing(this.SelfCharacter.Value.Facing,
                    this.Target.Value.transform.position.x - this.transform.position.x))
            {
                return TaskStatus.Success;
            }
            this.SelfCharacter.Value.Xinput = (float)((this.Target.Value.transform.position.x - this.transform.position.x > 0) ? 1 : -1);
        }
        else
        {
            if(this.timePassed >= this.MoveTime)
            {
                return TaskStatus.Success;
            }
            this.SelfCharacter.Value.Xinput = this.speed * (float)this.way;
            this.timePassed += Time.deltaTime;
        }
        return TaskStatus.Running;
    }
    
}
