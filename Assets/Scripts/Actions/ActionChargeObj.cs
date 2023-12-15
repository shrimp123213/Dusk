using Unity.VisualScripting;
using UnityEngine;
using UnityEngine.Windows;

[CreateAssetMenu(fileName = "ActionCharge", menuName = "Actions/Charge")]
public class ActionChargeObj : ActionBaseObj, IActionCharge
{
    public string AnimationKeyCharging;

    public bool ExtendPreviousAnimation;

    public float ChargeSpeed;

    public float ChargeSuccessTime;

    public bool ChargingStopMoving;

    public override bool MovableX(Character _m)
    {
        if (((ActionPeformStateCharge)_m.ActionState).Charging && !ChargingStopMoving)
        {
            return true;
        }
        return false;
    }
    public override bool MovableY(Character _m)
    {
        if (((ActionPeformStateCharge)_m.ActionState).Charging && !ChargingStopMoving)
        {
            return true;
        }
        return false;
    }

    public override float GetDamageRatio(Character _m)
    {
        ActionPeformStateCharge actionPeformStateCharge = (ActionPeformStateCharge)_m.ActionState;
        if (!actionPeformStateCharge.Success)
        {
            return DamageRatio * actionPeformStateCharge.ChargeAmount;
        }
        return DamageRatio * 1.5f;
    }

    public virtual void Charge(Character _m)
    {
        ActionPeformStateCharge actionPeformStateCharge = (ActionPeformStateCharge)_m.ActionState;
        if (actionPeformStateCharge.Charging)
        {
            actionPeformStateCharge.ChargeAmount = Mathf.Clamp(Time.deltaTime * ChargeSpeed + actionPeformStateCharge.ChargeAmount, 0f, 1f);
            actionPeformStateCharge.Charging = _m.Charging;
            if (!actionPeformStateCharge.Charging)
            {
                _m.HitEffect.SetTimeSlow(TimeSlowAmount);
                actionPeformStateCharge.Success = actionPeformStateCharge.ChargeAmount > ChargeSuccessTime;
                if (actionPeformStateCharge.Success)
                {
                    SkillCharge.i.SetAmount(0f);

                    //放開時播BurstCharge1Success
                    AnimatorExtensions.RebindAndRetainParameter(_m.Ani);
                    //_m.Ani.Rebind();
                    _m.Ani.Play(AnimationKey);
                    _m.Ani.Update(0f);
                    _m.ActionState.Clip = _m.Ani.GetCurrentAnimatorClipInfo(0)[0].clip;
                    _m.ActionState.TotalFrame = Mathf.RoundToInt(_m.ActionState.Clip.length * _m.ActionState.Clip.frameRate);

                    //_m.Inputs.Remove(InputKey.BurstRelease);
                }
                else
                {
                    foreach (InputKey inputKey in _m.Inputs)
                    {
                        //Debug.Log(inputKey);
                    }

                    //Debug.Log(_m.TryLink(PreviousId, true));

                    //actionPeformStateCharge.Linked = _m.TryLink(PreviousId);

                    //_m.Inputs.Remove(InputKey.BurstRelease);
                }
            }
            else
            {
                SkillCharge.i.SetAmount(actionPeformStateCharge.ChargeAmount / 1f);
            }
        }
    }

    public override void EndAction(Character _m)
    {
        base.EndAction(_m);
        SkillCharge.i.SetAmount(0f);
        _m.SpeedFactor = 1f;
    }

    public override ActionPeformState StartAction(Character _m)//按下時播BurstCharge1
    {
        _m.SpeedFactor = 0.35f;
        if (!ExtendPreviousAnimation)
        {
            AnimatorExtensions.RebindAndRetainParameter(_m.Ani); 
            //_m.Ani.Rebind();
            _m.Ani.Play(AnimationKeyCharging);
            _m.Ani.Update(0f);
        }
        SkillCharge.i.SetText(DisplayName);
        SkillCharge.i.SetSuccessTime(ChargeSuccessTime);
        //Debug.Log("A ChargeAble Action Started !");

        //if (!IsHeavyAttack)
        //    AerutaDebug.i.Feedback.LightAttackCount--;
        //else
        //    AerutaDebug.i.Feedback.HeavyAttackCount--;
        //AerutaDebug.i.Feedback.ChargeAttackCount++;

        return new ActionPeformStateCharge();
    }

    public override void ProcessAction(Character _m)
    {
        if (((ActionPeformStateCharge)_m.ActionState).Charging)
        {
            Charge(_m);
        }
        else
        {
            base.ProcessAction(_m);
        }
    }

    public override void Init(Character _m)
    {
        base.Init(_m);
    }

    public override void HitSuccess(Character _m, Character _hitted, IHitable IHitable, Vector2 _ClosestPoint)
    {
        base.HitSuccess(_m, _hitted, IHitable, _ClosestPoint);

    }
}

public interface IActionCharge
{
    void Charge(Character _m);
}

public class ActionPeformStateCharge : ActionPeformState
{
    public bool Charging = true;

    public float ChargeAmount;

    public bool Success;

    public override bool IsInLifeTime(int _frame, float _lifeTime)
    {
        if (_lifeTime == -1)
        {
            return true;
        }
        else
        {
            float Start = (float)_frame / (float)TotalFrame;
            float End = Start + _lifeTime;

            if (ChargeAmount >= Start)
            {
                return ChargeAmount <= End;
            }
            return false;
        }
    }
}