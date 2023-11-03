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

    private bool hitSuccess;

    public bool BlockSuccess;

    private Character _hitted;
    private IHitable IHitable;
    private Vector2 _ClosestPoint;

    public override ActionPeformState StartAction(Character _m)
    {
        hitSuccess = false;
        BlockSuccess = false;
        _hitted = null;
        IHitable = null;
        _ClosestPoint = Vector2.zero;

        collider = _m.GetComponent<BoxCollider2D>();

        originOffset = collider.offset;
        originSize = collider.size;

        return base.StartAction(_m);
    }

    public override void Charge(Character _m)
    {
        ActionPeformStateCharge actionPeformStateCharge = (ActionPeformStateCharge)_m.ActionState;
        if (actionPeformStateCharge.Charging)
        {
            actionPeformStateCharge.ChargeAmount = Mathf.Clamp(Time.deltaTime * ChargeSpeed + actionPeformStateCharge.ChargeAmount, 0f, 1f);
            actionPeformStateCharge.Charging = _m.Charging;
            if (!actionPeformStateCharge.Charging)
            {
                foreach (AttackTiming attackSpot in _m.NowAction.AttackSpots)
                {
                    if (actionPeformStateCharge.IsWithinFrame(attackSpot.KeyFrameFrom, attackSpot.KeyFrameEnd))
                    {
                        if (actionPeformStateCharge.IsWithinFrame(BlockStartFrame, BlockEndFrame))
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

                _m.HitEffect.SetTimeSlow(TimeSlowAmount);
                actionPeformStateCharge.Success = actionPeformStateCharge.ChargeAmount > ChargeSuccessTime;
                if (actionPeformStateCharge.Success)
                {
                    SkillCharge.i.SetAmount(0f);

                    //©ñ¶}®É¼½BurstCharge1Success
                    _m.Ani.Rebind();
                    _m.Ani.Play(AnimationKey);
                    _m.Ani.Update(0f);
                    _m.ActionState.Clip = _m.Ani.GetCurrentAnimatorClipInfo(0)[0].clip;
                    _m.ActionState.TotalFrame = Mathf.RoundToInt(_m.ActionState.Clip.length * _m.ActionState.Clip.frameRate);

                    _m.Inputs.Remove(InputKey.BurstRelease);
                }
                else
                {
                    foreach (InputKey inputKey in _m.Inputs)
                    {
                        //Debug.Log(inputKey);
                    }

                    //Debug.Log(_m.TryLink(PreviousId, true));

                    actionPeformStateCharge.Linked = _m.TryLink(PreviousId);

                    _m.Inputs.Remove(InputKey.BurstRelease);
                }
            }
            else
            {
                SkillCharge.i.SetAmount(actionPeformStateCharge.ChargeAmount / 1f);

                _m.Blocking = false;

                collider.offset = originOffset;
                collider.size = originSize;

                _m.Ani.GetComponentInChildren<SpriteRenderer>().color = Color.white;
            }
        }

    }

    public override void ProcessAction(Character _m)
    {
        ActionPeformStateCharge actionPeformStateCharge = (ActionPeformStateCharge)_m.ActionState;
        if (hitSuccess && !_m.Blocking && !BlockSuccess && actionPeformStateCharge.IsAfterFrame(BlockEndFrame))
        {
            base.HitSuccess(_m, _hitted, IHitable, _ClosestPoint);
        }

        base.ProcessAction(_m);
    }

    public override void HitSuccess(Character _m, Character _hitted, IHitable IHitable, Vector2 _ClosestPoint)
    {
        hitSuccess = true;
    }

    public override void EndAction(Character _m)
    {

        _m.Blocking = false;

        collider.offset = originOffset;
        collider.size = originSize;

        _m.Ani.GetComponentInChildren<SpriteRenderer>().color = Color.white;

        base.EndAction(_m);

    }

    //private void InBlock
}
