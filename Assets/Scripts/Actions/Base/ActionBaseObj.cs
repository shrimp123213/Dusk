using System;
using System.Collections.Generic;
using Unity.VisualScripting;
using UnityEngine;
using static FunkyCode.Light2D;

[CreateAssetMenu(fileName = "ActionNormal", menuName = "Actions/Normal")]
public class ActionBaseObj : ScriptableObject
{
    public string Id;

    public string PreviousId;

    public string DisplayName;

    [Header("動畫")]
    public string AnimationKey;

    public int InterruptLevel;

    public bool InterruptSameLevel;

    public AnimationClip Clip;

    public float DamageRatio;

    public DamageType DamageType;

    [Header("判定點")]
    public List<AttackTiming> AttackSpots;

    [Header("攻擊次數上限")]
    public int HitMax;

    [Header("攻擊成功時將空中的敵人往自己拉")]
    public bool SuckEffect;

    [Header("連技")]
    public List<ActionLink> Links;

    [Space]
    [Header("動作過程的位移")]
    public List<ActionMovement> Moves;

    [Space]
    [Header("攻擊成功時附加力道")]
    public Vector2 ApplyForce;

    public bool ForceBasedOnFacing;

    public bool UsePopup;

    public float TimeSlowAmount;

    public float OrbCost;

    public float OrbRecovery;

    public float EndActionFloatTime;

    public bool GroundOnly;

    public bool ResetCanAttack;

    public virtual void Init(Character _m)
    {
    }

    public virtual bool Movable(Character _m)
    {
        return false;
    }

    public virtual ActionPeformState StartAction(Character _m)
    {
        if (ResetCanAttack && (bool)_m.Player)
        {
            _m.Player.CanAttack = true;
        }
        _m.Ani.Play(AnimationKey);
        _m.Ani.Update(0f);
        if (TimeSlowAmount > 0f)
        {
            _m.HitEffect.SetTimeSlow(TimeSlowAmount);
        }
        return new ActionPeformState();
    }

    public virtual void EndAction(Character _m)
    {
        _m.SetAnimationIdle();
        _m.NowAction = null;
        if (EndActionFloatTime > 0f)
        {
            _m.LowGravityTime = EndActionFloatTime;
        }
    }

    public virtual void HitSuccess(Character _m, Character _hitted)
    {
    }

    public virtual float GetDamageRatio(Character _m)
    {
        return DamageRatio;
    }

    public virtual void ProcessAction(Character _m)
    {
        if (_m.NowAction == null)
        {
            return;
        }
        ActionPeformState actionState = _m.ActionState;
        actionState.SetTime(_m.Ani.GetCurrentAnimatorStateInfo(0).normalizedTime);
        if (!actionState.CanDoThingsThisUpdate())
        {
            return;
        }
        foreach (AttackTiming attackSpot in _m.NowAction.AttackSpots)
        {
            if (!actionState.IsWithinFrame(attackSpot.KeyFrameFrom, attackSpot.KeyFrameEnd))
            {
                continue;
            }
            Vector3 vector = Vector3Utli.CacuFacing(attackSpot.Offset, _m.Facing);
            Collider2D[] array = Physics2D.OverlapBoxAll(_m.transform.position + vector, attackSpot.Range, 0f, LayerMask.GetMask("Character"));
            Vector2 debugVector = _m.transform.position + vector;
            Vector2 topRight = attackSpot.Range / 2;
            Vector2 topLeft = new Vector2(-attackSpot.Range.x, attackSpot.Range.y) / 2;
            Vector2 bottomRight = new Vector2(attackSpot.Range.x, -attackSpot.Range.y) / 2;
            Vector2 bottomLeft = -attackSpot.Range / 2;
            Debug.DrawLine(debugVector + topRight, debugVector + topLeft);
            Debug.DrawLine(debugVector + topRight, debugVector + bottomRight);
            Debug.DrawLine(debugVector + topLeft, debugVector + bottomLeft);
            Debug.DrawLine(debugVector + bottomRight, debugVector + bottomLeft);
            foreach (Collider2D collider2D in array)
            {
                if (!(collider2D.gameObject != _m.gameObject) || _m.isMaxHit(collider2D.gameObject, _m.NowAction.HitMax))
                {
                    continue;
                }
                bool num = collider2D.TryGetComponent<IHitable>(out var IHitable) && IHitable.TakeDamage(new Damage(_m.Attack.Final * GetDamageRatio(_m), DamageType), _m);
                _m.RegisterHit(collider2D.gameObject);
                if (num)
                {
                    _m.AttackLand();
                    //CameraManager.i.GenerateImpulse(DamageRatio);
                    if (collider2D.CompareTag("Breakable"))
                    {
                        return;
                    }
                    Character component = collider2D.GetComponent<Character>();
                    HitSuccess(_m, component);
                    float y = 0f;
                    if (SuckEffect)
                    {
                        y = _m.transform.position.y - component.transform.position.y;
                    }
                    component.TakeForce(Vector3Utli.CacuFacing(_m.NowAction.ApplyForce, ForceBasedOnFacing ? Vector3Utli.GetFacingByPos(_m.transform, component.transform) : _m.Facing), new Vector2(0f, y));
                    _ = (component.transform.position - _m.transform.position).normalized;
                }
            }
        }
        if (AnimationKey == "Claw4sp")
        {
            _m.transform.GetChild(0).eulerAngles = new Vector3(0f, 0f, -45f * _m.Facing);
        }
        if (AnimationKey == "Evade")
        {
            _m.transform.GetChild(0).eulerAngles = new Vector3(0f, 0f, 0f);
        }
        TryRegisterMove(_m, actionState.YinputWhenAction);
        if (!actionState.Linked && _m.NowAction.Links.Count > 0 && actionState.IsAfterFrame(_m.NowAction.Links[0].Frame) && actionState.IsInLifeTime(_m.NowAction.Links[0].LifeTime) && _m.StoredMoves.Count <= 0) 
        {
            if (AnimationKey == "Claw4sp")
            {
                _m.transform.GetChild(0).eulerAngles = new Vector3(0f, 0f, 0f);
            }
            actionState.Linked = _m.TryLink(PreviousId);
        }
        if (actionState.ActionTime >= 1f && !actionState.Linked)
        {
            if (AnimationKey == "Claw4sp")
            {
                _m.transform.GetChild(0).eulerAngles = new Vector3(0f, 0f, 0f);
            }
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

    public void TryRegisterMove(Character _m, float _verticalPower = 0f)
    {
        ActionPeformState actionState = _m.ActionState;
        if (actionState.CurrMoveIndex < _m.NowAction.Moves.Count && actionState.IsAfterFrame(_m.NowAction.Moves[actionState.CurrMoveIndex].KeyFrame))
        {
            _m.StoredMoves.Add(new ForceMovement(_m.NowAction.Moves[actionState.CurrMoveIndex], new Vector3(0f, _verticalPower)));
            actionState.CurrMoveIndex++;
        }
    }
}


[Serializable]
public class AttackTiming
{
    public int KeyFrameFrom;

    public int KeyFrameEnd;

    public Vector3 Offset;

    public Vector2 Range;
}


[Serializable]
public class ActionLink
{
    public int Frame;

    public float LifeTime = -1;

    public InputKey Key1;

    public InputKey KeyArrow;

    public string LinkAcionId;

    public bool CanChangeFace;

    public string PreviousId;
}
