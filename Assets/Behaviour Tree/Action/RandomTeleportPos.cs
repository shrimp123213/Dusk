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

    public float LowestX;

    public bool Local;
    public bool NotRamdom;

    public override void OnStart()
    {
        float selfY = this.transform.position.y;
        float selfX = this.transform.position.x;
        float targetX = Target.Value.transform.position.x;

        LowestX = (targetX > 0) ? LowestX : -LowestX;

        if (!NotRamdom)
        {
            if (!Local)
            {
                RandomPos = new Vector2(Random.Range(MinX + LowestX, MaxX), selfY);
            }
            else
            {
                RandomPos = new Vector2(Random.Range(LowestX + targetX, MaxX), selfY);

                if (LowestX + targetX > MaxX || LowestX + targetX < MinX)
                {
                    RandomPos.x = targetX - LowestX;
                }
            }
        }
        else
        {
            RandomPos = new Vector2(LowestX, selfY);
            
            if (selfX + LowestX > MaxX)
            {
                RandomPos.x = MinX;
            }
            else if(selfX + LowestX < MinX)
            {
                RandomPos.x = MaxX;
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
