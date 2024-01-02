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
    public float HintspawnOffsetY = 0;

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
        if (!hintSpawned && actionState.IsAfterFrame(1))
        {
            float omenEuler = OmenSpawnEuler;
            if (HintSpawnFlip) omenEuler += (this.transform.position.x > this.Target.Value.transform.position.x) ? 180 : 0;

            Vector3 hintPos = new Vector3(transform.position.x, transform.position.y + HintspawnOffsetY, transform.position.z);
            Transform omenTransform = OmenSpawnPointWithTarget ? OmenSpawnPoint.Value.transform : null;

            GameObject.Instantiate(AttackRangeHint, hintPos, Quaternion.Euler(0, 0, omenEuler), omenTransform);
            //Omen.transform.localScale = new Vector3(this.SelfCharacter.Value.Facing,1,1);

            hintSpawned = true;
        }
    }
}
