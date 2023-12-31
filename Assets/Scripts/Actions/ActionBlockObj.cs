using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using static ActionPeformStateBlock;

[CreateAssetMenu(fileName = "ActionBlock", menuName = "Actions/Block")]
public class ActionBlockObj : ActionBaseObj
{
    [Header("ActionBlock")]

    public int PerfectFrameStart;

    public int NormalFrameStart;

    public int BackswingFrameStart;

    [Header("value/100000")]
    public int PerfectMorphRecovery;

    public int NormalMorphRecovery;

    public BlockReaction[] blockReactions;

    public override ActionPeformState StartAction(Character _m)
    {
        AnimatorExtensions.RebindAndRetainParameter(_m.Ani);
        //_m.Ani.Rebind();
        _m.Ani.Play(AnimationKey);
        _m.Ani.Update(0f);

        return new ActionPeformStateBlock();
    }

    public override void ProcessAction(Character _m)
    {
        if (_m.NowAction == null)
        {
            return;
        }
        ActionPeformStateBlock actionState = (ActionPeformStateBlock)_m.ActionState;
        actionState.SetTime(_m.Ani.GetCurrentAnimatorStateInfo(0).normalizedTime);
        if (!actionState.CanDoThingsThisUpdate())
        {
            return;
        }


        TrySetBlockState(actionState, _m);


        TryRegisterMove(_m, actionState.YinputWhenAction);

        if (actionState.ActionTime >= 1f)
        {
            EndAction(_m);
        }
    }

    public override void EndAction(Character _m)
    {
        ActionPeformStateBlock actionState = (ActionPeformStateBlock)_m.ActionState;
        if (actionState.blockState != BlockState.PerfectBlock)
        {
            _m.SetAnimationIdle();
        }

        _m.Blocking = false;

        _m.NowAction = null;
        if (EndActionFloatTime > 0f)
        {
            _m.LowGravityTime = EndActionFloatTime;
        }
    }

    public void TrySetBlockState(ActionPeformStateBlock actionState, Character _m)
    {
        switch (actionState.blockState)
        {
            case BlockState.Forswing:
                if (!actionState.IsWithinFrame(0, PerfectFrameStart - 1))
                {
                    Instantiate(AerutaDebug.i.BlockFlashYellow, _m.transform.position + new Vector3(.5f * _m.Facing, .5f, 0f), Quaternion.identity, null);
                    actionState.blockState = BlockState.Perfect;
                    _m.Blocking = true;
                }
                break;
            case BlockState.Perfect:
                if (!actionState.IsWithinFrame(PerfectFrameStart, NormalFrameStart - 1))
                {
                    Instantiate(AerutaDebug.i.BlockFlashBlue, _m.transform.position + new Vector3(.5f * _m.Facing, .5f, 0f), Quaternion.identity, null);
                    actionState.blockState = BlockState.Normal;
                }
                break;
            case BlockState.Normal:
                if (!actionState.IsWithinFrame(NormalFrameStart, BackswingFrameStart - 1))
                {
                    actionState.blockState = BlockState.Backswing;
                    _m.Blocking = false;
                }
                break;
            case BlockState.Backswing:
                break;

            case BlockState.PerfectBlock:
                break;
            case BlockState.NormalBlock:
                break;
        }
    }

    public void Block(Character _m, Vector2 _ClosestPoint)
    {
        ActionPeformStateBlock actionState = (ActionPeformStateBlock)_m.ActionState;

        AnimatorExtensions.RebindAndRetainParameter(_m.Ani);
        //_m.Ani.Rebind();
        if (actionState.IsWithinFrame(PerfectFrameStart, NormalFrameStart - 1))
        {
            _m.Ani.Play(blockReactions[0].AnimationKey);
            actionState.blockState = BlockState.PerfectBlock;

            Instantiate(AerutaDebug.i.BlockEffectPerfect, _ClosestPoint, Quaternion.identity, null);

            if (blockReactions[0].KnockbackMove.TargetDistance.x != 0 || blockReactions[0].KnockbackMove.TargetDistance.y != 0)
                _m.StoredMoves.Add(new ForceMovement(blockReactions[0].KnockbackMove, new Vector3(0f, 0f), _m.transform.position));

            _m.Player.Morph.Add(((ActionBlockObj)_m.NowAction).PerfectMorphRecovery);

            Debug.Log("Perfect");
        }
        else
        {
            _m.Ani.Play(blockReactions[1].AnimationKey);
            actionState.blockState = BlockState.NormalBlock;

            Instantiate(AerutaDebug.i.BlockEffectNormal, _ClosestPoint, Quaternion.identity, null);

            if (blockReactions[1].KnockbackMove.TargetDistance.x != 0 || blockReactions[1].KnockbackMove.TargetDistance.y != 0) 
                _m.StoredMoves.Add(new ForceMovement(blockReactions[1].KnockbackMove, new Vector3(0f, 0f), _m.transform.position));

            _m.Player.Morph.Add(((ActionBlockObj)_m.NowAction).NormalMorphRecovery);

            Debug.Log("Normal");
        }
        _m.Ani.Update(0f);
        _m.ActionState.Clip = _m.Ani.GetCurrentAnimatorClipInfo(0)[0].clip;
        _m.ActionState.TotalFrame = Mathf.RoundToInt(_m.ActionState.Clip.length * _m.ActionState.Clip.frameRate);

        _m.Blocking = false;

        if (actionState.blockState == BlockState.PerfectBlock)
        {
            EndAction(_m);
        }
    }
}

public class ActionPeformStateBlock : ActionPeformState
{
    public enum BlockState
    {
        Forswing,
        Perfect,
        Normal,
        Backswing,
        
        PerfectBlock,
        NormalBlock,
    }
    public BlockState blockState = BlockState.Forswing;
}

[Serializable]
public class BlockReaction
{
    public string AnimationKey;

    public bool OnlyInterruptByDash;

    public bool Knockback;

    public ActionMovement KnockbackMove;
}