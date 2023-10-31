using System;
using System.Collections.Generic;
using Unity.VisualScripting;
using Unity.VisualScripting.Dependencies.Sqlite;
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

    public float DamageRatio;

    public DamageType DamageType;

    [Header("判定點")]
    public List<AttackTiming> AttackSpots;

    [Header("攻擊次數上限")]
    public int HitMax;

    [Header("攻擊成功時將空中的敵人往自己拉")]
    public bool SuckEffect;

    [Header("是否可中斷行動")]
    public bool CanInterruptAction;

    [Header("連技")]
    public List<ActionLink> Links;

    [Space]
    [Header("動作過程的位移")]
    public List<ActionMovement> Moves;

    [Space]
    [Header("停、啟用碰撞箱的時間點")]
    public List<ToggleCollider> Toggles;

    [Space]
    [Header("瞬間傳送")]
    public List<Teleport> Teleports;

    [Space]
    [Header("攻擊成功時附加力道")]
    public Vector2 ApplyForce;

    public bool ForceBasedByPos;

    public bool UsePopup;

    public float TimeSlowAmount;
    
    public bool NeedButterfly;

    public float OrbCost;

    public float OrbRecovery;

    public float EvadeEnergyRecovery;

    public float EndActionFloatTime;

    public bool GroundOnly;

    public bool ResetCanAttack;

    private bool[] IsTriggered;

    private bool[] IsTeleported;

    public virtual void Init(Character _m)
    {
        foreach (ActionMovement movement in _m.NowAction.Moves) 
        {
            if (movement.CanEvade)
            {
                ActionPeformState actionState = _m.ActionState;

                float StartDelay = (float)movement.StartEvadeFrame / (float)actionState.TotalFrame;
                float Duration = 0;
                if (movement.EndEvadeFrame == -1)
                    Duration = (float)(actionState.TotalFrame - movement.StartEvadeFrame) / (float)actionState.TotalFrame;
                else
                    Duration = (float)(movement.EndEvadeFrame - movement.StartEvadeFrame) / (float)actionState.TotalFrame;

                var Afterimage = _m.gameObject.AddComponent<AfterimageGenerator>();
                Afterimage.SetLifeTime(StartDelay, Duration);

            }
        }

        IsTriggered = new bool[_m.NowAction.Toggles.Count];
        IsTeleported = new bool[_m.NowAction.Teleports.Count];
    }

    public virtual bool Movable(Character _m)
    {
        return false;
    }

    //public virtual bool TryNewConditionPossible(Character _m)有新的使用條件再用
    //{
    //    return true;
    //}

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
        _m.Evading = false;
        if (_m.NowAction.Toggles.Count > 0)
        {
            int i = 0;
            foreach (ToggleCollider toggle in _m.NowAction.Toggles)
            {
                if (!IsTriggered[i] && actionState.IsAfterFrame(toggle.KeyFrame))
                {
                    IsTriggered[i] = true;
                    _m.Collider.enabled = toggle.IsActive;
                }
                i++;
            }
        }
        if (_m.NowAction.Teleports.Count > 0)
        {
            int i = 0;
            foreach (Teleport teleport in _m.NowAction.Teleports)
            {
                if (!IsTeleported[i] && actionState.IsAfterFrame(teleport.KeyFrame))
                {
                    IsTeleported[i] = true;
                    _m.Rigid.MovePosition(teleport.Local ? teleport.Pos + _m.transform.position : teleport.Pos);
                }
                i++;
            }
        }
        foreach (ActionMovement movement in _m.NowAction.Moves)
        {
            if (movement.CanEvade && actionState.IsWithinFrame(movement.StartEvadeFrame, movement.EndEvadeFrame))
            {
                _m.Evading = true;
                break;
            }
        }
        foreach (AttackTiming attackSpot in _m.NowAction.AttackSpots)
        {
            Vector3 vector = Vector3Utli.CacuFacing(attackSpot.Offset, _m.Facing);
            Vector2 debugVector = _m.transform.position + vector;
            Vector2 topRight = attackSpot.Range / 2;
            Vector2 topLeft = new Vector2(-attackSpot.Range.x, attackSpot.Range.y) / 2;
            Vector2 bottomRight = new Vector2(attackSpot.Range.x, -attackSpot.Range.y) / 2;
            Vector2 bottomLeft = -attackSpot.Range / 2;
            if (!actionState.IsWithinFrame(attackSpot.KeyFrameFrom, attackSpot.KeyFrameEnd))
            {
                Debug.DrawLine(debugVector + topRight, debugVector + topLeft, Color.cyan);
                Debug.DrawLine(debugVector + topRight, debugVector + bottomRight, Color.cyan);
                Debug.DrawLine(debugVector + topLeft, debugVector + bottomLeft, Color.cyan);
                Debug.DrawLine(debugVector + bottomRight, debugVector + bottomLeft, Color.cyan);
                continue;
            }
            Debug.DrawLine(debugVector + topRight, debugVector + topLeft, Color.magenta);
            Debug.DrawLine(debugVector + topRight, debugVector + bottomRight, Color.magenta);
            Debug.DrawLine(debugVector + topLeft, debugVector + bottomLeft, Color.magenta);
            Debug.DrawLine(debugVector + bottomRight, debugVector + bottomLeft, Color.magenta);
            Collider2D[] array = Physics2D.OverlapBoxAll(_m.transform.position + vector, attackSpot.Range, 0f, LayerMask.GetMask("Character"));
            foreach (Collider2D collider2D in array)
            {
                if (!(collider2D.gameObject != _m.gameObject) || _m.isMaxHit(collider2D.gameObject, _m.NowAction.HitMax))
                {
                    continue;
                }
                bool num = collider2D.TryGetComponent<IHitable>(out var IHitable) && IHitable.TakeDamage(new Damage(_m.Attack.Final * GetDamageRatio(_m), DamageType), _m, (!collider2D.GetComponent<Character>().ImmuneInterruptAction && CanInterruptAction));
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
                    component.TakeForce(Vector3Utli.CacuFacing(_m.NowAction.ApplyForce, ForceBasedByPos ? Vector3Utli.GetFacingByPos(_m.transform, component.transform) : _m.Facing), new Vector2(0f, y), CanInterruptAction);
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
        if (!actionState.Linked && _m.NowAction.Links.Count > 0 && actionState.IsInLifeTime(_m.NowAction.Links[0].Frame, _m.NowAction.Links[0].LifeTime) && _m.StoredMoves.Count <= 0) 
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

    public string LinkActionId;

    public bool CanChangeFace;

    public string PreviousId;
}


[Serializable]
public class ToggleCollider
{
    public int KeyFrame;

    public bool IsActive;
}

[Serializable]
public class Teleport
{
    public int KeyFrame;

    public bool Local;//打勾的話是原本的位置+Pos，沒有的話是世界座標

    public Vector3 Pos;
}

