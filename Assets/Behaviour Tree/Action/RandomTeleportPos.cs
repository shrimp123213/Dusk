using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using BehaviorDesigner.Runtime;
using BehaviorDesigner.Runtime.Tasks;

public class RandomTeleportPos : EnemyActionBase
{
    public Vector2 RandomPos;
    
    public float MinX;
    public float MaxX;

    public bool Local;

    public override void OnStart()
    {
        float selfY = this.transform.position.y;
        float selfX = this.transform.position.x;
        if (!Local)
        {
            RandomPos = new Vector2(Random.Range(MinX, MaxX), selfY);
        }
        else
        {
            RandomPos = new Vector2(Random.Range(MinX+selfX, MaxX+selfX), selfY);
        }
        Debug.Log(this.SelfCharacter.Value.transform.position);
        this.SelfCharacter.Value.TeleportKeyReference = this.RandomPos;
        Debug.Log(RandomPos);
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
