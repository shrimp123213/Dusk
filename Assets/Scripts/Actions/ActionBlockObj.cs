using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UIElements;
using static ActionPeformStateBlock;
using static UnityEngine.RuleTile.TilingRuleOutput;

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

    public string[] blockReactionsId;

    public float CatMorphPauseTimeAmount_Perfect;
    public float CatMorphPauseTimeAmount_Normal;

    public override ActionPeformState StartAction(Character _m)
    {
        base.m = _m;

        if (ResetCanAttack && (bool)_m.Player)
        {
            _m.Player.CanAttack = true;
        }
        AnimatorExtensions.RebindAndRetainParameter(_m.Ani);
        //_m.Ani.Rebind();
        _m.Ani.Play(AnimationKey);
        _m.Ani.Update(0f);

        if (TimeSlowAmount > 0f)
        {
            _m.HitEffect.SetTimeSlow(TimeSlowAmount);
        }

        _m.TimedLinks.Clear();
        foreach (ActionLink link in Links)
        {
            _m.TimedLinks.Add(new TimedLink(link));
        }

        if (ClearStoredMoves)
        {
            _m.StoredMoves.Clear();
        }

        foreach (InputCooldown set in SetCooldowns)
        {
            foreach (InputCooldown cooldown in _m.Player.InputCooldowns)
            {
                if (cooldown.Key == set.Key)
                {
                    cooldown.Time = set.Time;
                    break;
                }
            }
        }

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
                    //Instantiate(AerutaDebug.i.BlockFlashYellow, _m.transform.position + new Vector3(.5f * _m.Facing, .5f, 0f), Quaternion.identity, null);
                    actionState.blockState = BlockState.Perfect;
                    _m.Blocking = true;
                }
                break;
            case BlockState.Perfect:
                if (!actionState.IsWithinFrame(PerfectFrameStart, NormalFrameStart - 1))
                {
                    //Instantiate(AerutaDebug.i.BlockFlashBlue, _m.transform.position + new Vector3(.5f * _m.Facing, .5f, 0f), Quaternion.identity, null);
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
            AerutaDebug.i.SpawnPostBlurZoomIn(_ClosestPoint, true);
            _m.Player.HitEffect.SetGlobalSlow(.5f, 1);

            Vector2 direction = (Vector2)_m.transform.position - _ClosestPoint;
            float angle = Mathf.Atan2(direction.y, direction.x) * Mathf.Rad2Deg;

            Instantiate(AerutaDebug.i.BlockEffectPerfect, _ClosestPoint, Quaternion.AngleAxis(angle, Vector3.forward), null);

            _m.Player.Morph.Add(((ActionBlockObj)_m.NowAction).PerfectMorphRecovery);

            _m.Player.CatMorphPauseTime = CatMorphPauseTimeAmount_Perfect;

            _m.StartAction(ActionLoader.i.Actions[blockReactionsId[0]]);
        }
        else
        {
            AerutaDebug.i.SpawnPostBlurZoomOut(_ClosestPoint);

            Instantiate(AerutaDebug.i.BlockEffectNormal, _ClosestPoint, Quaternion.identity, null);

            _m.Player.Morph.Add(((ActionBlockObj)_m.NowAction).NormalMorphRecovery);

            _m.Player.CatMorphPauseTime = CatMorphPauseTimeAmount_Normal;

            _m.StartAction(ActionLoader.i.Actions[blockReactionsId[1]]);
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
