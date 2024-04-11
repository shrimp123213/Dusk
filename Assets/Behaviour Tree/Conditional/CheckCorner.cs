using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using BehaviorDesigner.Runtime;
using BehaviorDesigner.Runtime.Tasks;

public class CheckCorner : EnemyConditionalBase
{
    public float checkDistance = 1f;
    public LayerMask layerMask;
    public Vector2 checkDirection = Vector2.right;
    public Vector2 checkOffset = Vector2.zero;
    public bool checkGround = false;
    public bool checkWall = false;
    public bool checkCeiling = false;

    public override TaskStatus OnUpdate()
    {
        Vector2 checkPosition = this.SelfCharacter.Value.transform.position + (Vector3)checkOffset;
        RaycastHit2D hit = Physics2D.Raycast(checkPosition, checkDirection, checkDistance, layerMask);
        if (hit.collider != null)
        {
            if (checkGround && hit.normal.y > 0.5f)
            {
                return TaskStatus.Success;
            }
            if (checkWall && hit.normal.x != 0)
            {
                return TaskStatus.Success;
            }
            if (checkCeiling && hit.normal.y < -0.5f)
            {
                return TaskStatus.Success;
            }
        }
        return TaskStatus.Failure;
    }
}
