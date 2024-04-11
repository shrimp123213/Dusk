using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using BehaviorDesigner.Runtime;
using BehaviorDesigner.Runtime.Tasks;

public class EnemyActionBase : Action
{
    [HideInInspector]
    public SharedCharacter SelfCharacter;
    
    public SharedFloat priority;
    
    public override float GetPriority()
    {
        return priority.Value;
    }
    
    public override void OnAwake()
    {
        if (base.Owner.GetVariable("SelfCharacter").GetValue() == null)
        {
            base.Owner.SetVariableValue("SelfCharacter",base.GetComponent<Character>());
            Debug.Log(base.Owner.GetVariable("SelfCharacter"));
        }
        this.SelfCharacter.Value = base.Owner.GetVariable("SelfCharacter").GetValue() as Character;
    }
    
}
