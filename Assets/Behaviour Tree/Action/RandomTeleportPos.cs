using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using BehaviorDesigner.Runtime;
using BehaviorDesigner.Runtime.Tasks;

public class RandomTeleportPos : EnemyActionBase
{
    public SharedTransform Target;
    
    public Vector2 RandomPos;
    
    public float MinX;
    public float MaxX;
    public float TeleportY = 0f;
    
    public float LowestX;
    public float HighestX = 13f;

    public bool Local;
    public bool NotRamdom;
    public bool TraceTarget;

    public override void OnStart()
    {
        float selfY = this.transform.position.y;
        float selfX = this.transform.position.x;
        float targetX = Target.Value.transform.position.x;
        
        
        LowestX = (targetX > 0) ? Mathf.Abs(LowestX) : -LowestX;

        if (!NotRamdom)
        {
            if (!Local)
            {
                RandomPos = new Vector2(Random.Range(MinX + LowestX, MaxX), selfY);
            }
            else
            {
                RandomPos = new Vector2(Random.Range(LowestX + targetX, HighestX + targetX), selfY);

                if (RandomPos.x > MaxX || RandomPos.x < MinX)
                {
                    RandomPos.x = targetX - Random.Range(LowestX, MaxX);
                    Mathf.Clamp(RandomPos.x, MinX, MaxX);
                }
            }
        }
        else
        {
            if (TraceTarget)
            {
                RandomPos = new Vector2(targetX, selfY + TeleportY);
            }
            else
            {
                RandomPos = new Vector2(LowestX, selfY);

                if (selfX + LowestX > MaxX)
                {
                    RandomPos.x = MinX;
                }
                else if (selfX + LowestX < MinX)
                {
                    RandomPos.x = MaxX;
                }
            }
        }
        
        //Debug.Log(this.SelfCharacter.Value.transform.position);
        this.SelfCharacter.Value.TeleportKeyReference = this.RandomPos;
        //Debug.Log(RandomPos);
    }

    public override void OnEnd()
    {
        //this.SelfCharacter.Value.TeleportKeyReference = this.RandomPos;
    }

    public override TaskStatus OnUpdate()
    {
        if (RandomPos == this.SelfCharacter.Value.TeleportKeyReference)
        {
            return TaskStatus.Success;
        }
        return TaskStatus.Running;
    }
}
