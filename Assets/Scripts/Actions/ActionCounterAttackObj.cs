using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[CreateAssetMenu(fileName = "ActionCounterAttack", menuName = "Actions/CounterAttack")]
public class ActionCounterAttackObj : ActionClawObj
{
    public override ActionPeformState StartAction(Character _m)
    {
        _m.Player.InvincibleState.Invincible(999f, false);

        _m.Player.HitEffect.SetGlobalSlow(0.0001f, 1);

        return base.StartAction(_m);
    }

    public override void SpawnEffect(Character _m)
    {
        GameObject spawnEffect = Effect;
        Transform parent = null;
        if (EnableJumpVersion && !m.isGround)
        {
            spawnEffect = Effect_jump;
            parent = _m.transform;
        }
            

        Vector3 offsetFacing = Vector3Utility.CacuFacing(offset, _m.Facing);
        EffectAni = Instantiate(spawnEffect, _m.transform.position + offsetFacing, _m.Facing == 1 ? Quaternion.Euler(Vector3.zero) : Quaternion.Euler(new Vector3(0, 180, 0)), parent).GetComponent<Animator>();
        //EffectAni.Play(_AnimationKey);
        //EffectAni.Update(0f);
    }

    public override void EndAction(Character _m)
    {
        _m.Player.InvincibleState.Invincible(0f, false);

        base.EndAction(_m);
    }
}
