using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using TheKiwiCoder;

[System.Serializable]
public class DistanceCheck : ActionNode
{
    [Tooltip("Target")]
    public NodeProperty<GameObject> target = new NodeProperty<GameObject> { defaultValue = null };
    
    [Tooltip("Returns success when the remaining distance is less than this amount")]
    public NodeProperty<float> tolerance = new NodeProperty<float> { defaultValue = 12.0f };
    
    private float _distance;    //與Target的距離
    
    protected override void OnStart() {
        
    }

    protected override void OnStop() {
    }

    protected override State OnUpdate() {
        if (context != null && target != null)
        {
            Transform targetTransform = target.Value.transform;
            
            _distance = (context.transform.position - target.Value.transform.position).sqrMagnitude; //計算距離
        }
        
        if (_distance > tolerance.Value)    //如果距離大於容許值，則返回成功
        {
            return State.Success;
        }
        
        if (_distance < tolerance.Value)    //如果距離小於容許值，則返回失敗
        {
            return State.Failure;
        }
        
        return State.Running;
    }
}
