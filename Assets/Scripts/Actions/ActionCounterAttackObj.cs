using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[CreateAssetMenu(fileName = "ActionCounterAttack", menuName = "Actions/CounterAttack")]
public class ActionCounterAttackObj : ActionClawObj
{
    public override void SpawnEffect(Character _m)
    {
        GameObject effect = AerutaDebug.i.CounterAttackEffect;
        if (Id == "CatCounterAttack") 
            effect = AerutaDebug.i.CatCounterAttackEffect;


        ClawEffectAnis.Clear();
        for (int i = 0; i < ClawEffectCount; i++)
        {
            Vector3 vector = Vector3Utility.CacuFacing(new Vector2(1.1f, .2f), _m.Facing);
            ClawEffectAnis.Add(Instantiate(effect, _m.transform.position + vector, _m.Facing == 1 ? Quaternion.Euler(Vector3.zero) : Quaternion.Euler(new Vector3(0, 180, 0)), _m.transform).GetComponent<Animator>());
            ClawEffectAnis[i].Play(_AnimationKey);
            ClawEffectAnis[i].Update(0f);
        }
    }
}
