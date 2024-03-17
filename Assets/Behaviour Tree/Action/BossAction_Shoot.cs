using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using BehaviorDesigner.Runtime;
using BehaviorDesigner.Runtime.Tasks;
using Unity.VisualScripting;

public class BossAction_Shoot : EnemyStartAction
{
    public GameObject AttackRangeHint;

    public bool HintSpawnFlip = false;
    public Vector3 HintspawnOffset;

    private bool hintSpawned;

    public override void OnStart()
    {
        base.OnStart();
        //Action
        hintSpawned = false;
    }

    public override TaskStatus OnUpdate()
    {
        if (this.Fail)
        {
            return TaskStatus.Failure;
        }
        if (this.SelfCharacter.Value.isActing)
        {
            TrySpawnOmen();
            TrySpawnHint();
            return TaskStatus.Running;
        }
        return TaskStatus.Success;
    }

    private void TrySpawnHint()
    {
        ActionPeformState actionState = SelfCharacter.Value.ActionState;
        if (!hintSpawned)
        {
            float omenEuler = OmenSpawnEuler;
            if (HintSpawnFlip) omenEuler = (this.transform.position.x > this.Target.Value.transform.position.x) ? 180f : 0f;

            Vector3 hintPos = transform.position + HintspawnOffset;
            Transform omenTransform = OmenSpawnPointWithTarget ? OmenSpawnPoint.Value.transform : null;

            GameObject attackRangeHint = GameObject.Instantiate(AttackRangeHint, hintPos, Quaternion.Euler(new Vector3(0, omenEuler, -5)), null);

            hintSpawned = true;
        }
    }
}
