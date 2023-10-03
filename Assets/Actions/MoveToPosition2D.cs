using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using TheKiwiCoder;

[System.Serializable]
public class MoveToPosition2D : ActionNode
{
    [Tooltip("How fast to move")]
    public NodeProperty<float> speed = new NodeProperty<float> { defaultValue = 5.0f };

    [Tooltip("Target")]
    public NodeProperty<GameObject> target = new NodeProperty<GameObject> { defaultValue = null };
    
    
    protected override void OnStart() {
        if (context.gameObject != null)
        {
            //Rigidbody2D contextRb = context.gameObject.GetComponent<Rigidbody2D>();
            Transform targetTransform = target.Value.transform;

            if (target!=null)
            {
                context.transform.position= Vector2.MoveTowards(context.transform.position, targetTransform.position, speed.Value * Time.deltaTime);
                if(context.transform.position.x >= targetTransform.position.x)
                {
                    context.transform.GetChild(0).localScale = new Vector3(-5, 5, 5);
                    /*new Vector3(context.transform.GetChild(0).localScale.x*-1f,
                        context.transform.GetChild(0).localScale.y,
                        context.transform.GetChild(0).localScale.z);*/
                }
                else
                {
                    context.transform.GetChild(0).localScale = new Vector3(5, 5, 5);
                    /*new Vector3(context.transform.GetChild(0).localScale.x*1f,
                        context.transform.GetChild(0).localScale.y,
                        context.transform.GetChild(0).localScale.z);*/
                }
            }
        }
    }

    protected override void OnStop() {
    }

    protected override State OnUpdate() {
        return State.Success;
    }
}
