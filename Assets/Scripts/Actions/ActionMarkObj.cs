using System.Collections;
using System.Collections.Generic;
using Unity.VisualScripting;
using UnityEngine;


[CreateAssetMenu(fileName = "ActionMark", menuName = "Actions/Mark")]
public class ActionMarkObj : ActionBaseObj
{
    public override ActionPeformState StartAction(Character _m)
    {
        Butterfly.i.Cooldown = Butterfly.i.CooldownMax.Final;
        return base.StartAction(_m);
    }

    public override void HitSuccess(Character _m, Character _hitted)
    {
        Butterfly.i.MarkTarget = _hitted;
    }

    public override void ProcessAction(Character _m)
    {
        base.ProcessAction(_m);

        ActionPeformState actionState = _m.ActionState;
        bool isAfterAllAttackFrame = true;
        foreach (AttackTiming attackSpot in _m.NowAction.AttackSpots)
        {
            if (!actionState.IsAfterFrame(attackSpot.KeyFrameEnd))
            {
                isAfterAllAttackFrame = false;
                continue;
            }
        }

        if (isAfterAllAttackFrame && !(bool)Butterfly.i.MarkTarget)
        {
            Butterfly.i.Disappear();
        }
    }

    //public override bool TryNewConditionPossible(Character _m)有新的使用條件再用
    //{
    //    return Butterfly.i.Cooldown <= 0f;
    //}
}
