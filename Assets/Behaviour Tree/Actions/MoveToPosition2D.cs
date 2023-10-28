using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using TheKiwiCoder;

[System.Serializable]
public class MoveToPosition2D : ActionNode
{
    [Tooltip("How fast to move")]
    public NodeProperty<float> speed = new NodeProperty<float> { defaultValue = 5.0f };
    
    [Tooltip("Returns success when the remaining distance is less than this amount")]
    public NodeProperty<float> tolerance = new NodeProperty<float> { defaultValue = 1.0f };

    [Tooltip("Target")]
    public NodeProperty<GameObject> target = new NodeProperty<GameObject> { defaultValue = null };
    
    [Tooltip("Character")]
    public NodeProperty<Character> character  = new NodeProperty<Character> { defaultValue = null };
    
    [Tooltip("Move Clip")]
    public NodeProperty<string> clip  = new NodeProperty<string> { defaultValue = null };
    
    private float _distance;    //與Target的距離
    
    
    protected override void OnStart()
    {
        character.Value.Xinput = 0;
    }

    protected override void OnStop() {
        character.Value.Xinput = 0;
    }

    protected override State OnUpdate() { //移動到目標位置
        if (context != null && target != null)
        {
            Animator Ani =context.transform.GetComponentInChildren<Animator>();
            Ani.Play(clip.Value);
            
            //Rigidbody2D contextRb = context.gameObject.GetComponent<Rigidbody2D>();
            Transform targetTransform = target.Value.transform;
            
            context.transform.position = Vector2.MoveTowards(context.transform.position,
                                                                 new Vector2(targetTransform.position.x,context.transform.position.y),
                                                        speed.Value * Time.deltaTime);
            
            _distance = (context.transform.position - target.Value.transform.position).sqrMagnitude; //計算距離
            if (context.transform.position.x >= targetTransform.position.x) //如果目標在左邊，則翻轉
            {
                character.Value.Xinput = -1;
                /*context.transform.GetChild(0).localScale = new Vector3(-5, 5, 5);
                new Vector3(context.transform.GetChild(0).localScale.x*-1f,
                    context.transform.GetChild(0).localScale.y,
                    context.transform.GetChild(0).localScale.z);*/
            }
            else if (context.transform.position.x <= targetTransform.position.x)
            {
                character.Value.Xinput = 1;
                /*context.transform.GetChild(0).localScale = new Vector3(5, 5, 5);
                new Vector3(context.transform.GetChild(0).localScale.x*1f,
                    context.transform.GetChild(0).localScale.y,
                    context.transform.GetChild(0).localScale.z);*/
            }
        }
        
        
        if (_distance < tolerance.Value)    //如果距離小於容許值，則返回成功
        {
            return State.Success;
        }
        if(context == null || target == null)
        {
            return State.Failure;
        }
        
        //Debug.Log("Distance: " + _distance);
        return State.Running;
    }
}
