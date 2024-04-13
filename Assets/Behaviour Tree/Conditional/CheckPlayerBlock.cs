using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using BehaviorDesigner.Runtime;
using BehaviorDesigner.Runtime.Tasks;

public class CheckPlayerBlock : EnemyConditionalBase
{
    public SharedTransform Target;
    //public ActionPeformStateBlock actionPeformStateBlock;
    //public string rpActionName;
    
    //public SharedFloat priority;
    
    //public BehaviorTree behaviorTree;
    //private Task task;
    
    public Character _m;

    public override void OnAwake()
    {
        _m = this.Target.Value.GetComponent<Character>();
        //task = behaviorTree.FindTaskWithName(rpActionName);
        //behaviorTree.SetVariableValue(priority.Name, 0f);
    }

    public override TaskStatus OnUpdate()
    {
        if (this.Target.IsShared)
        {
            //actionPeformStateBlock = (ActionPeformStateBlock) _m.ActionState ?? null;
            
            //if (_m.Blocking && actionPeformStateBlock is {blockState: ActionPeformStateBlock.BlockState.Perfect})
            if(_m.isPerfectBlock)
            {
                Debug.Log("PlayerBlockPerfect");
                //behaviorTree.SetVariableValue(priority.Name, 1f);
                return TaskStatus.Success;
            }
        }
        return TaskStatus.Failure;
    }
}
