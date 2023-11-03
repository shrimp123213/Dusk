using FunkyCode.SuperTilemapEditorSupport.Light.Shadow;
using System.Collections;
using System.Collections.Generic;
using UnityEditor.Experimental.GraphView;
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

    public override void Charge(Character _m)
    {
        base.Charge(_m);

        ActionPeformStateCharge actionPeformStateCharge = (ActionPeformStateCharge)_m.ActionState;
        if (!actionPeformStateCharge.Charging)
        {
            ActionPeformState actionState = _m.ActionState;
            foreach (AttackTiming attackSpot in _m.NowAction.AttackSpots)
            {
                if (actionState.IsWithinFrame(attackSpot.KeyFrameFrom, attackSpot.KeyFrameEnd))
                {
                    if (actionState.IsWithinFrame(BlockStartFrame, BlockEndFrame))
                    {
                        _m.Blocking = true;

                        if (_m.Facing == 1)
                        {
                            collider.offset = attackSpot.Offset;
                            collider.size = attackSpot.Range;
                        }
                        else
                        {
                            collider.offset = new Vector2(-attackSpot.Offset.x, attackSpot.Offset.y);
                            collider.size = attackSpot.Range;
                        }

                        _m.Ani.GetComponentInChildren<SpriteRenderer>().color = Color.magenta;
                    }
                }
            }
        }
        else
        {
            _m.Blocking = false;

            collider.offset = originOffset;
            collider.size = originSize;

            _m.Ani.GetComponentInChildren<SpriteRenderer>().color = Color.white;
        }
    }

    public override void ProcessAction(Character _m)
    {
        base.ProcessAction(_m);
    }

    public override void HitSuccess(Character _m, Character _hitted, IHitable IHitable, Vector2 _ClosestPoint)
    {
        if (_m.Blocking)
        {
            if (_hitted == Butterfly.i.MarkTarget)
            {
                Butterfly.i.MarkTime = Butterfly.i.MarkTimeMax.Final;
            }
            else if(!Butterfly.i.isAppear)
            {
                Butterfly.i.Appear();
                Butterfly.i.MarkTarget = _hitted;
                Butterfly.i.transform.parent = null;

                AerutaDebug.i.Feedback.MarkCount++;
            }

            Instantiate(AerutaDebug.i.BlockEffect, _ClosestPoint, Quaternion.identity, null);
        }
        else
            base.HitSuccess(_m, _hitted, IHitable, _ClosestPoint);
    }

    public override void EndAction(Character _m)
    {
        base.EndAction(_m);

        _m.Blocking = false;

        collider.offset = originOffset;
        collider.size = originSize;

        _m.Ani.GetComponentInChildren<SpriteRenderer>().color = Color.white;
    }

    //private void InBlock
}
