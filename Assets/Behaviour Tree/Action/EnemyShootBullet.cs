using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using BehaviorDesigner.Runtime;
using BehaviorDesigner.Runtime.Tasks;

public class EnemyShootBullet : EnemyActionBase
{
    public List<Vector2> BulletSpawnPosition;
    
    public GameObject BulletPrefab;
    
    public float BulletSpeed;
    
    public override void OnStart()
    {
        base.OnStart();
    }

    public override void OnEnd()
    {
        base.OnEnd();
    }
    
    public override TaskStatus OnUpdate()
    {
        if (this.SelfCharacter.Value.isActing)
        {
            return TaskStatus.Running;
        }
        return TaskStatus.Success;
    }
}
