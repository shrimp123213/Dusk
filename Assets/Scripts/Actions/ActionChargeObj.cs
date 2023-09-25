using UnityEngine;

[CreateAssetMenu(fileName = "ActionCharge", menuName = "Actions/Charge")]
public class ActionChargeObj : ActionBaseObj, IActionCharge
{
    public string AnimationKeyCharging;

    public bool ExtendPreviousAnimation;

    public float ChargeSpeed;

    public float ChargeSuccessTime;

    public override bool Movable(Character _m)
    {
        if (((ActionPeformStateCharge)_m.ActionState).Charging)
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

    public void Charge(Character _m)
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
                    _m.Ani.Play(AnimationKey);//放開時播BurstCharge1Success
                    _m.Ani.Update(0f);
                    _m.ActionState.Clip = _m.Ani.GetCurrentAnimatorClipInfo(0)[0].clip;
                    _m.ActionState.TotalFrame = Mathf.RoundToInt(_m.ActionState.Clip.length * _m.ActionState.Clip.frameRate);
                }
                else
                {
                    if (!actionPeformStateCharge.Linked && _m.NowAction.Links.Count > 0 && _m.StoredMoves.Count <= 0)
                    {
                        actionPeformStateCharge.Linked = _m.TryLink(PreviousId);
                    }
                    if (!actionPeformStateCharge.Linked)
                    {
                        EndAction(_m);
                        _m.NowAction = null;
                        _m.Ani.Play("Idle");
                        _m.Ani.Update(0f);
                        if (_m.Inputs.Contains(InputKey.Claw))
                        {
                            _m.Inputs.Remove(InputKey.Claw);
                        }
                        if ((bool)_m.TextInput)
                        {
                            _m.TextInput.text = "";
                        }
                    }
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
            _m.Ani.Play(AnimationKeyCharging);
            _m.Ani.Update(0f);
        }
        SkillCharge.i.SetText(DisplayName);
        SkillCharge.i.SetSuccessTime(ChargeSuccessTime);
        Debug.Log("A ChargeAble Action Started !");
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
}