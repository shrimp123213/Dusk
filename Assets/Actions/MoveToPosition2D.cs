using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using TheKiwiCoder;

[System.Serializable]
public class MoveToPosition2D : ActionNode
{
    [Tooltip("How fast to move")]
    public NodeProperty<float> speed = new NodeProperty<float> { defaultValue = 5.0f };

    [Tooltip("Stop within this distance of the target")]
    public NodeProperty<float> stoppingDistance = new NodeProperty<float> { defaultValue = 0.1f };

    [Tooltip("Updates the agents rotation along the path")]
    public NodeProperty<bool> updateRotation = new NodeProperty<bool> { defaultValue = true };

    [Tooltip("Maximum acceleration when following the path")]
    public NodeProperty<float> acceleration = new NodeProperty<float> { defaultValue = 40.0f };

    [Tooltip("Returns success when the remaining distance is less than this amount")]
    public NodeProperty<float> tolerance = new NodeProperty<float> { defaultValue = 1.0f };

    [Tooltip("Target Position")]
    public NodeProperty<Vector2> targetPosition = new NodeProperty<Vector2> { defaultValue = Vector2.zero };
    
    [Tooltip("Move Time")]
    public NodeProperty<float> moveTime = new NodeProperty<float> { defaultValue = 3.0f };
    
    
    protected override void OnStart() {
        if (context.gameObject != null)
        {
            Rigidbody2D contextRb = context.gameObject.GetComponent<Rigidbody2D>();
            //contextRb.velocity = new Vector2(speed.Value,0);
            if(contextRb.transform.position.x < targetPosition.Value.x)
            {
                contextRb.velocity = new Vector2(speed.Value,0);
            }
            else
            {
                contextRb.velocity = new Vector2(-speed.Value,0);
            }
        }
    }

    protected override void OnStop() {
    }

    protected override State OnUpdate() {
        return State.Success;
    }
}
