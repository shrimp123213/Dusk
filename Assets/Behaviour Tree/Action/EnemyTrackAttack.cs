using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using BehaviorDesigner.Runtime;
using BehaviorDesigner.Runtime.Tasks;

public class EnemyTrackAttack : EnemyStartAction
{
    public bool fixedTime = false;
    
    // 使用Lerp計算位移時間
    public float minDistance = 0f; // 最小距離
    public float maxDistance = 10f; // 最大距離
    public float minTime = 0.1f; // 最小時間
    public float maxTime = 0.7f; // 最大時間
    
    private Vector2 targetDistance;

    private ActionMovement actionMovement;
    
    private bool tracked = false;
    
    private int facing;
    
    public override void OnStart()
    {
        base.OnStart();
        actionMovement = Action.Moves[Action.Moves.Count - 1];
    }
    
    public override TaskStatus OnUpdate()
    {
        base.OnUpdate();
        /*if (!tracked)
        {
            facing = (this.Target.Value.transform.position.x > this.SelfCharacter.Value.transform.position.x) ? 1 : -1;
            
            targetDistance = new Vector2((this.Target.Value.transform.position.x - this.SelfCharacter.Value.transform.position.x) * facing,
                actionMovement.TargetDistance.y);
            actionMovement.TargetDistance = targetDistance;
        }*/
        
        if (this.SelfCharacter.Value.isActing)
        {
            TryTrack();
            return TaskStatus.Running;
        }
        return TaskStatus.Success;
    }
    
    public override void OnEnd()
    {
        base.OnEnd();
        tracked = false;
    }
    
    public virtual void TryTrack()
    {
        ActionPeformState actionState = this.SelfCharacter.Value.ActionState;
        if (actionState.IsAfterFrame(actionMovement.KeyFrame))
        {
            if (!tracked)
            {
                facing = (this.Target.Value.transform.position.x > this.SelfCharacter.Value.transform.position.x)
                    ? 1
                    : -1;

                float distance = Mathf.Abs(this.Target.Value.transform.position.x - this.SelfCharacter.Value.transform.position.x);
                targetDistance = new Vector2((this.Target.Value.transform.position.x - this.SelfCharacter.Value.transform.position.x) * facing, actionMovement.TargetDistance.y);
                actionMovement.TargetDistance = targetDistance;
                
                if (fixedTime)
                {
                    
                    float lerpFactor = (distance - minDistance) / (maxDistance - minDistance); // 插值因子
                    float time = Mathf.Lerp(minTime, maxTime, lerpFactor); // 計算時間

                    actionMovement.FinishTime = time;
                }
                else
                {
                    //actionMovement.FinishTime = maxTime;
                }
            }
            tracked = true;
        }
    }
}
