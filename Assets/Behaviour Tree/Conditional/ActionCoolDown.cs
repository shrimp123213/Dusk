using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using BehaviorDesigner.Runtime;
using BehaviorDesigner.Runtime.Tasks;

public class ActionCoolDown : EnemyConditionalBase
{
    public string CoolDownActionName;
    public float CoolDownTime;

    public BehaviorTree behaviorTree;
    private Task task;
    
    // The time that the task started to wait.
    private float startTime = -1;
    // Remember the time that the task is paused so the time paused doesn't contribute to the wait time.
    private float pauseTime;
    private bool CDing = false;

    public override void OnAwake()
    {
        behaviorTree = GetComponent<BehaviorTree>();
        task = behaviorTree.FindTaskWithName(CoolDownActionName);
        /*if (task != null)
        {
            if (task.OnUpdate() == TaskStatus.Success || task.OnUpdate() == TaskStatus.Failure)
            {
                startTime = Time.time;
            }
        }*/
    }

    public override TaskStatus OnUpdate()
    {
        CDing = startTime + CoolDownTime > Time.time;
        Debug.Log("CDing:"+CDing);
        if(!CDing)
        {
            startTime = task.OnUpdate() == TaskStatus.Success ? Time.time : 0;
        }

        Debug.Log("CD:" + ((startTime + CoolDownTime) - Time.time));
        
        if(CDing)
        {
            return TaskStatus.Failure;
        }
        
        return TaskStatus.Success;

        // Otherwise we are still waiting.
        //return TaskStatus.Running;
    }

    public override void OnReset()
    {
        //startTime = 0;
        //CDing = false;
    }

    /*public override void OnPause(bool paused)
    {
        if (paused) {
            // Remember the time that the behavior was paused.
            pauseTime = Time.time;
        } else {
            // Add the difference between Time.time and pauseTime to figure out a new start time.
            startTime += (Time.time - pauseTime);
        }
    }*/
}
