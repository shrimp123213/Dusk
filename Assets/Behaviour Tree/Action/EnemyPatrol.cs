using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using BehaviorDesigner.Runtime;
using BehaviorDesigner.Runtime.Tasks;
using Unity.VisualScripting;

public class EnemyPatrol : EnemyActionBase
{
    public SharedTransform Target;
    public SharedTransformList PatrolPoints;
    public float IdleTime;
    public string AnimationName;
    public float WaitTime;  // 新增：敵人在每個巡邏點停留的時間

    private float timer;
    private Animator Ani;
    private int patrolIndex = 0;
    private bool isPatrolForward = true;

    private float speed;
    private int way = 1;

    public override void OnStart()
    {
        Ani = this.transform.GetComponentInChildren<Animator>();
        this.way=(Random.Range(0, 100) > 50) ? 1 : -1 ;
        this.speed = this.Target.Value == null ? Random.Range(0.3f, 0.5f) : 1f;
    }

    public override TaskStatus OnUpdate()
    {
        if(timer >= IdleTime)
        {
            timer -= Time.deltaTime;
            return TaskStatus.Running;
        }
        else
        {
            Patrol();
            return TaskStatus.Success;
        }
        return TaskStatus.Running;
        /*timer += Time.deltaTime;
        if(timer>= IdleTime)
        {
            Patrol();
        }
        return TaskStatus.Running;*/
    }

    public override void OnEnd()
    {
        timer = 0;
    }

    public void Patrol()
    {
        if (AnimationName != null)
        {
            Ani.Play(AnimationName);
        }
/*
        if (isPatrolForward)
        {
            patrolIndex++;
            if (patrolIndex >= PatrolPoints.Value.Count)
            {
                patrolIndex = PatrolPoints.Value.Count - 2;
                isPatrolForward = false;
            }
        }
        else
        {
            patrolIndex--;
            if (patrolIndex < 0)
            {
                patrolIndex = 1;
                isPatrolForward = true;
            }
        }
*/
        //this.SelfCharacter.Value.Xinput = this.speed * (float)this.way;

        this.transform.position = Vector2.MoveTowards(this.transform.position, PatrolPoints.Value[patrolIndex].position, this.SelfCharacter.Value.Speed.Final * Time.deltaTime);
        this.SelfCharacter.Value.Xinput = (float)((this.PatrolPoints.Value[patrolIndex].transform.position.x - this.transform.position.x > 0) ? 1 : -1);
        
        if (Vector2.Distance(this.transform.position, PatrolPoints.Value[patrolIndex].transform.position) <.1f && Vector3Utility.IsFacing(this.SelfCharacter.Value.Facing,
                this.PatrolPoints.Value[patrolIndex].transform.position.x - this.transform.position.x))
        {
            patrolIndex++;
            if (patrolIndex >= PatrolPoints.Value.Count)
            {
                patrolIndex = 0;
            }
        }
    }
}

/*public class EnemyPatrol : EnemyActionBase
{
    public SharedTransform Target;
    
    //public Vector2[] PatrolPoints;
    public SharedTransformList PatrolPoints;

    public float IdleTime;
    public string AnimationName;
    
    private float timer;
    private Animator Ani;
    private int patrolIndex = 0;
    
    private float speed;
    private int way = 1;

    public override void OnStart()
    {
        Ani = this.transform.GetComponentInChildren<Animator>();
        this.way=(Random.Range(0, 100) > 50) ? 1 : -1 ;
        this.speed = this.Target.Value == null ? Random.Range(0.3f, 0.5f) : 1f;
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
        
        if (patrolIndex >= PatrolPoints.Value.Count)
        {
            patrolIndex = 0;
        }
        
        this.SelfCharacter.Value.Xinput = this.speed * (float)this.way;
        
        if (Vector2.Distance(this.transform.position, PatrolPoints.Value[patrolIndex].transform.position) <.1f && Vector3Utility.IsFacing(this.SelfCharacter.Value.Facing,
                this.PatrolPoints.Value[patrolIndex].transform.position.x - this.transform.position.x))
        {
            Vector2 temp = PatrolPoints.Value[0].position;
            for (int i = patrolIndex; i < PatrolPoints.Value.Count - 1; i++)
            {
                PatrolPoints.Value[i].position = PatrolPoints.Value[i + 1].position;
                this.transform.position = Vector2.MoveTowards(this.transform.position, PatrolPoints.Value[i].position, this.SelfCharacter.Value.Speed.Final);
            }
            PatrolPoints.Value[PatrolPoints.Value.Count - 1].position = temp;
        }
        
        /*if (Vector2.Distance(this.transform.position, PatrolPoints.Value[patrolIndex].transform.position) <.1f)
        {
            Vector2 temp = PatrolPoints.Value[0].position;
            for (int i = 0; i < PatrolPoints.Value.Count - 1; i++)
            {
                PatrolPoints.Value[i].position = PatrolPoints.Value[i + 1].position;
                this.transform.position = Vector2.MoveTowards(this.transform.position, PatrolPoints.Value[i].position, this.SelfCharacter.Value.Speed.Final);
            }
            PatrolPoints.Value[PatrolPoints.Value.Count - 1].position = temp;
        }
    }
}*/
