using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using TheKiwiCoder;

public class TEST : MonoBehaviour
{
    private Character character;
    
    public BehaviourTreeInstance behaviourTreeInstance;

    private BlackboardKey<Vector2> _key;

    /*private void Start()
    {
        Vector2 value = behaviourTreeInstance.GetBlackboardValue<Vector2>("TeleportTarget");
        behaviourTreeInstance.SetBlackboardValue("TeleportTarget", value);
        
        _key=behaviourTreeInstance.FindBlackboardKey<Vector2>("TeleportTarget");
    }

    private void Update()
    {
        _key.value+=Vector2.one;
    }*/
}
