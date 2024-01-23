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
        base.m = _m;

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

        _m.Blocking = false;

        base.EndAction(_m);
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
        }
    }

    public void Block(Character _m, Vector2 _ClosestPoint)
    {
        ActionPeformStateBlock actionState = (ActionPeformStateBlock)_m.ActionState;

        _m.Blocking = false;

        if (actionState.IsWithinFrame(PerfectFrameStart, NormalFrameStart - 1))
        {
            Instantiate(AerutaDebug.i.BlockEffectPerfect, _ClosestPoint, Quaternion.identity, null);

            _m.Player.Morph.Add(((ActionBlockObj)_m.NowAction).PerfectMorphRecovery);

            Debug.Log("Perfect");

            _m.StartAction(ActionLoader.i.Actions["BlockPerfect"]);
        }
        else
        {
            Instantiate(AerutaDebug.i.BlockEffectNormal, _ClosestPoint, Quaternion.identity, null);

            _m.Player.Morph.Add(((ActionBlockObj)_m.NowAction).NormalMorphRecovery);

            Debug.Log("Normal"); 
            
            _m.StartAction(ActionLoader.i.Actions["BlockNormal"]);
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