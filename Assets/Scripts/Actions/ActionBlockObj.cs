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

        //TryBlocking
        if (actionState.IsWithinFrame(0, PerfectFrameStart - 1))//Forswing
        {

        }

        TryRegisterMove(_m, actionState.YinputWhenAction);

        if (actionState.ActionTime >= 1f)
        {
            EndAction(_m);
        }
    }

    public void SetBlockState(ActionPeformStateBlock actionState)
    {
        switch (actionState.blockState)
        {
            case BlockState.Forswing:
                if (!actionState.IsWithinFrame(0, PerfectFrameStart - 1))
                {
                    actionState.blockState = BlockState.Perfect;
                }
                break;
        }

        


    }

    public void Block(Character _m)
    {
        AnimatorExtensions.RebindAndRetainParameter(_m.Ani);
        //_m.Ani.Rebind();
        if (_m.ActionState.IsWithinFrame(PerfectFrameStart, NormalFrameStart - 1))
            _m.Ani.Play(blockReactions[0].AnimationKey);
        else
            _m.Ani.Play(blockReactions[1].AnimationKey);
        _m.Ani.Update(0f);


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

    public BlockState GetBlockState(int Start, int End)
    {
        switch (blockState)
        {
            case BlockState.Forswing:

                break;
        }

        if (IsWithinFrame(Start, End)) 
        {
            

        }

        return blockState;
    }
}

[Serializable]
public class BlockReaction
{
    public string AnimationKey;

    public bool OnlyInterruptByDash;

    public bool Knockback;

    public ActionMovement KnockbackMove;
}