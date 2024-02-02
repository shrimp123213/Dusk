using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using BehaviorDesigner.Runtime;
using BehaviorDesigner.Runtime.Tasks;
using Unity.VisualScripting;

public class EnemyPatrol : EnemyActionBase
{
    public SharedTransform Target;
    
    public Vector2[] PatrolPoints;

    public float IdleTime;
    public string AnimationName;
    
    private float timer;
    private Animator Ani;
    private int patrolIndex;

    public override void OnStart()
    {
        Ani = this.transform.GetComponentInChildren<Animator>();
    }
    
    public override TaskStatus OnUpdate()
    {
        timer += Time.deltaTime;
        if(timer>= IdleTime)
        {
            Patrol();
        }
        return TaskStatus.Running;
    }

    public override void OnEnd()
    {
        timer = 0;
    }
    
    public void Patrol()
    {
        if (AnimationName != null)
        {
            //Ani.Rebind();
            Ani.Play(AnimationName);
            //Ani.Update(0f);
        }
        
        if (Vector2.Distance(this.transform.position, PatrolPoints[patrolIndex]) <.1f)
        {
            Vector2 temp = PatrolPoints[0];
            for (int i = 0; i < PatrolPoints.Length - 1; i++)
            {
                PatrolPoints[i] = PatrolPoints[i + 1];
                this.transform.position = Vector2.MoveTowards(this.transform.position, PatrolPoints[i], this.SelfCharacter.Value.Speed.Final);
            }
            PatrolPoints[PatrolPoints.Length - 1] = temp;
        }
    }
}
