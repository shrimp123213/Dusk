using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using TheKiwiCoder;

[System.Serializable]
public class Attack : ActionNode
{
    [Tooltip("Character")]
    public NodeProperty<Character> character  = new NodeProperty<Character> { defaultValue = null };
    
    [Tooltip("Action Obj")]
    public NodeProperty<ActionBaseObj> action = new NodeProperty<ActionBaseObj> { defaultValue = null };
    
    protected override void OnStart()
    {
        Debug.Log("attack");   
        character.Value.StartAction(ActionLoader.i.Actions[action.Value.Id]);
        
    }
    

    protected override void OnStop() {
    }

    protected override State OnUpdate()
    {
        if (character.Value.NowAction == null)
        {
            return State.Success;
        }

        return State.Running;
    }
}
