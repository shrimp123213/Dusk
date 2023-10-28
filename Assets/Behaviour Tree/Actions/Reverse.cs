using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using TheKiwiCoder;

[System.Serializable]
public class Reverse : ActionNode
{
    [Tooltip("Move Clip")]
    public NodeProperty<string> clip  = new NodeProperty<string> { defaultValue = null };
    
    protected override void OnStart() {
    }

    protected override void OnStop() {
    }

    protected override State OnUpdate() {
        Animator Ani =context.transform.GetComponentInChildren<Animator>();
        Ani.Play(clip.Value);
        
        return State.Success;
    }
}
