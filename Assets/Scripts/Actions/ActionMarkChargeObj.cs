using FunkyCode.SuperTilemapEditorSupport.Light.Shadow;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[CreateAssetMenu(fileName = "ActionMarkCharge", menuName = "Actions/MarkCharge")]
public class ActionMarkChargeObj : ActionChargeObj
{
    public int BlockStartFrame;

    public int BlockEndFrame;

    private BoxCollider2D collider;

    private Vector2 originOffset;
    private Vector2 originSize;


    public override ActionPeformState StartAction(Character _m)
    {
        collider = _m.GetComponent<BoxCollider2D>();

        originOffset = collider.offset;
        originSize = collider.size;

        return base.StartAction(_m);
    }

    public override void ProcessAction(Character _m)
    {
        base.ProcessAction(_m);

        ActionPeformState actionState = _m.ActionState;
        foreach (AttackTiming attackSpot in _m.NowAction.AttackSpots)
        {
            if (actionState.IsWithinFrame(attackSpot.KeyFrameFrom, attackSpot.KeyFrameEnd))
            {
                if (actionState.IsWithinFrame(BlockStartFrame, BlockEndFrame))
                {
                    _m.Blocking = true;

                    collider.offset = attackSpot.Offset;
                    collider.size = attackSpot.Range;
                }
                else
                {
                    _m.Blocking = false;

                    collider.offset = originOffset;
                    collider.size = originSize;
                }
            }

        }
    }

    public override void EndAction(Character _m)
    {
        base.EndAction(_m);

        _m.Blocking = false;

        collider.offset = originOffset;
        collider.size = originSize;
    }

    //private void InBlock
}
