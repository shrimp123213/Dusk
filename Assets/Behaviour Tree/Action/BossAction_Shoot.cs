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
        if (!hintSpawned)
        {
            float omenEuler = OmenSpawnEuler;
            if (HintSpawnFlip) omenEuler = (this.transform.position.x > this.Target.Value.transform.position.x) ? 0f : 3.141593f;


            Vector3 hintPos = new Vector3(transform.position.x, transform.position.y + HintspawnOffsetY, transform.position.z);
            Transform omenTransform = OmenSpawnPointWithTarget ? OmenSpawnPoint.Value.transform : null;

            GameObject attackRangeHint = GameObject.Instantiate(AttackRangeHint, hintPos, Quaternion.identity, omenTransform);
            //Omen.transform.localScale = new Vector3(this.SelfCharacter.Value.Facing,1,1);
            
            var hint = attackRangeHint.transform.GetChild(0).GetComponent<ParticleSystem>().main;
            hint.startRotationY = omenEuler;

            hintSpawned = true;
        }
    }
}
