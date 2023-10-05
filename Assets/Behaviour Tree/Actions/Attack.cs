using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using TheKiwiCoder;

[System.Serializable]
public class Attack : ActionNode
{
    [Tooltip("Target")]
    public NodeProperty<GameObject> target = new NodeProperty<GameObject> { defaultValue = null };
    
    [Tooltip("Character")]
    public NodeProperty<Character> character  = new NodeProperty<Character> { defaultValue = null };
    
    
    
    protected override void OnStart()
    {
        Debug.Log("attack");   
        character.Value.StartAction(ActionLoader.i.Actions["Claw1"]);
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
