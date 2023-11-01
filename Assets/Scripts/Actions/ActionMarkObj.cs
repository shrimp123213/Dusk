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

    public override void HitSuccess(Character _m, Character _hitted, IHitable IHitable)
    {
        if (!Butterfly.i.isAppear)
            Butterfly.i.Appear();
        Butterfly.i.MarkTarget = _hitted;
        Butterfly.i.transform.parent = null;

        AerutaDebug.i.Feedback.MarkCount++;
    }

    public override void ProcessAction(Character _m)
    {
        base.ProcessAction(_m);

        if (_m.NowAction == null)
            return;

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

    public override void EndAction(Character _m)
    {
        if (Butterfly.i.isAppear && !(bool)Butterfly.i.MarkTarget)
            Butterfly.i.Disappear();

        base.EndAction(_m);
    }

    

    //public override bool TryNewConditionPossible(Character _m)有新的使用條件再用
    //{
    //    return Butterfly.i.Cooldown <= 0f;
    //}
}

