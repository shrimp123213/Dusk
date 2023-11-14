using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using BehaviorDesigner.Runtime;
using BehaviorDesigner.Runtime.Tasks;

public class ActionCoolDown : EnemyConditionalBase
{
    public string CoolDownActionName;
    public float CoolDownTime;
    
    // The time to wait
    private float waitDuration;
    // The time that the task started to wait.
    private float startTime;
    // Remember the time that the task is paused so the time paused doesn't contribute to the wait time.
    private float pauseTime;

    public override void OnStart()
    {
        startTime = Time.time;
        waitDuration = CoolDownTime;
    }

    public override TaskStatus OnUpdate()
    {
        if (this.SelfCharacter.Value.NowAction.Id == CoolDownActionName)
        {
            if (startTime + waitDuration < Time.time) {
                return TaskStatus.Success;
            }
            return TaskStatus.Failure;
            // Otherwise we are still waiting.
        }
        return TaskStatus.Running;
    }
    
    public override void OnPause(bool paused)
    {
        if (paused) {
            // Remember the time that the behavior was paused.
            pauseTime = Time.time;
        } else {
            // Add the difference between Time.time and pauseTime to figure out a new start time.
            startTime += (Time.time - pauseTime);
        }
    }
}
