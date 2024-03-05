using BehaviorDesigner.Runtime.Tasks.Unity.UnityParticleSystem;
using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Reflection;
using Unity.VisualScripting;
using UnityEngine;
using static UnityEngine.RuleTile.TilingRuleOutput;

[CreateAssetMenu(fileName = "ActionNormal", menuName = "Actions/Normal")]
public class ActionBaseObj : ScriptableObject
{
    public string Id;

    public string DisplayName;

    [Header("音效")]
    public string soundEffectName;

    [Header("動畫")]
    public string _AnimationKey;
    public string AnimationKey
    {
        get
        {
            if (EnableJumpVersion && !m.isGround)
                return _AnimationKey + "_jump";
            return _AnimationKey;
        }
    }
    public bool EnableJumpVersion;
    [Space(10f)]

    public int InterruptLevel;

    public bool InterruptSameLevel;

    public float DamageRatio;

    public DamageType DamageType;

    [Header("判定點")]
    public List<AttackTiming> AttackSpots;

    [Header("攻擊成功時將空中的敵人往自己拉")]
    public bool SuckEffect;

    [Header("是否可中斷行動")]
    public bool CanInterruptAction;

    [Header("是否觸發標記")]
    public bool CanTriggerMark;

    [Header("是否執行開始時清除所有位移")]
    public bool ClearStoredMoves;

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
    
    public float MorphCost;

    [Header("value/100000")]
    public int MorphRecovery;

    public int MorphRecoveryAdditionalByMark;
    [Space(10)]

    public float EvadeEnergyRecovery;

    public float EndActionFloatTime;

    public bool GroundOnly;

    public bool ResetCanAttack;

    public bool[] IsTriggered;

    public bool[] IsTeleported;

    public bool IsLightAttack;
    public bool IsHeavyAttack;

    public float HitStun;

    public bool IsMovableX;
    public bool IsMovableY;

    [Header("VelocityLimit")]
    public Vector2 LimitX = new Vector2(float.MinValue, float.MaxValue);
    public Vector2 LimitY = new Vector2(float.MinValue, float.MaxValue);
    [Space(10f)]

    public bool CanChangeFacingWhenActing;

    public bool CanJumpWhenActing;

    protected Character m;

    public virtual void Init(Character _m)
    {
        foreach (ActionMovement movement in _m.NowAction.Moves) 
        {
            //if (movement.CanEvade)
            {
                ActionPeformState actionState = _m.ActionState;

                float StartDelay = (float)movement.StartEvadeFrame / (float)actionState.TotalFrame * actionState.Clip.length;
                float Duration = 0;
                if (movement.EndEvadeFrame == -1)
                    Duration = (float)(actionState.TotalFrame - movement.StartEvadeFrame) / (float)actionState.TotalFrame * actionState.Clip.length;
                else
                    Duration = (float)(movement.EndEvadeFrame - movement.StartEvadeFrame) / (float)actionState.TotalFrame * actionState.Clip.length;

                var Afterimage = _m.gameObject.AddComponent<AfterimageGenerator>();
                Afterimage.IsSprite = _m.GetComponentInChildren<MeshRenderer>().enabled ? false : true;
                Afterimage.SetLifeTime(StartDelay, Duration);

            }
        }

        IsTriggered = new bool[_m.NowAction.Toggles.Count];
        IsTeleported = new bool[_m.NowAction.Teleports.Count];

        PlaySoundEffect();
    }

    public virtual bool MovableX(Character _m)
    {
        return IsMovableX;
    }
    public virtual bool MovableY(Character _m)
    {
        return IsMovableY;
    }
    public virtual Vector2 VelocityLimitX(Character _m)
    {
        return LimitX;
    }
    public virtual Vector2 VelocityLimitY(Character _m)
    {
        return LimitY;
    }
    public virtual bool CanChangeFacing(Character _m)
    {
        return CanChangeFacingWhenActing;
    }
    public virtual bool CanJump(Character _m)
    {
        return CanJumpWhenActing;
    }

    public virtual ActionPeformState StartAction(Character _m)
    {
        m = _m;

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

    public void TryEvade(Character _m, ActionPeformState actionState)
    {
        if (_m.Evading == false && !((bool)_m.Player && _m.Player.EvadeState.CanEvade))//閃避無敵結束
        {
            return;
        }

        foreach (ActionMovement movement in Moves)
        {
            if (movement.CanEvade)
            {
                if ((bool)_m.Player && _m.Player.EvadeState.CanEvade && !actionState.IsAfterFrame(movement.StartEvadeFrame))
                {
                    _m.Player.EvadeState.UseEvade(_m);
                    _m.Player.EvadeState.EvadingTransparency();
                    break;
                }
                else if (_m.Evading == true && actionState.IsWithinFrame(movement.StartEvadeFrame, movement.EndEvadeFrame))
                {
                    _m.Player.EvadeState.EvadingTransparency();
                    break;
                }
                else
                {
                    _m.Player.EvadeState.ReturnTransparency();
                    _m.Evading = false;
                    if ((bool)_m.Player)
                    {
                        //_m.Player.EvadeState.EvadeDistanceEffect.Stop();//停止閃避無敵時
                    }
                    break;
                }
            }
        }

    }

    public virtual void HitSuccess(Character _m, Character _hitted, IHitable IHitable, Vector2 _ClosestPoint)
    {
        if ((bool)_m.Player)
            Instantiate(AerutaDebug.i.PlayerAttackLandEffect, _ClosestPoint, Quaternion.Euler(Vector3.forward * 90 * Vector3Utility.GetFacingByPos(_m.transform, _hitted.transform)), null);
        //else
        //    Instantiate(AerutaDebug.i.BloodEffect, _ClosestPoint, Quaternion.Euler(Vector3.forward * 90 * Vector3Utility.GetFacingByPos(_m.transform, _hitted.transform)), null);

        if (IsLightAttack)
            AerutaDebug.i.Feedback.LightAttackCount++;
        //if (IsHeavyAttack)
        //    AerutaDebug.i.Feedback.HeavyAttackCount++;

    }

    public virtual void TriggerMark(Character _m, Character _hitted, IHitable IHitable)
    {
        _m.TriggerMark();

        //IHitable.TakeDamage(new Damage(10, DamageType.Mark), 0f, _m, !_hitted.ImmuneInterruptAction && CanInterruptAction);

        //_hitted累積體幹值

        //AerutaDebug.i.Feedback.MarkTriggerCount++;
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

        TryEvade(_m, actionState);
        
        if (_m.NowAction.Toggles.Count > 0)
        {
            int i = 0;
            foreach (ToggleCollider toggle in _m.NowAction.Toggles)
            {
                if (!IsTriggered[i] && actionState.IsAfterFrame(toggle.KeyFrame))
                {
                    IsTriggered[i] = true;
                    _m.transform.Find("CollisionDamageBox").GetComponent<Collider2D>().enabled = toggle.IsActive;
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

        int currentAttackSpot = -1;
        foreach (AttackTiming attackSpot in _m.NowAction.AttackSpots)
        {
            currentAttackSpot++;

            float angle = attackSpot.Angle * _m.Facing;

            Vector3 vector = Vector3Utility.CacuFacing(attackSpot.Offset, _m.Facing);
            Vector2 attackSpotCenter = _m.transform.position + vector;
            Vector2 topRight = attackSpot.Range / 2;
            //Vector2 topLeft = new Vector2(-attackSpot.Range.x, attackSpot.Range.y) / 2;
            //Vector2 bottomRight = new Vector2(attackSpot.Range.x, -attackSpot.Range.y) / 2;
            Vector2 bottomLeft = -attackSpot.Range / 2;
            if (!actionState.IsWithinFrame(attackSpot.KeyFrameFrom, attackSpot.KeyFrameEnd))
            {
                //Debug.DrawLine(debugVector + topRight, debugVector + topLeft, Color.cyan);
                //Debug.DrawLine(debugVector + topRight, debugVector + bottomRight, Color.cyan);
                //Debug.DrawLine(debugVector + topLeft, debugVector + bottomLeft, Color.cyan);
                //Debug.DrawLine(debugVector + bottomRight, debugVector + bottomLeft, Color.cyan);
                DrawRectangle(bottomLeft, topRight, attackSpotCenter, Quaternion.Euler(0f, 0f, angle), Color.cyan);
                continue;
            }
            //Debug.DrawLine(debugVector + topRight, debugVector + topLeft, Color.magenta);
            //Debug.DrawLine(debugVector + topRight, debugVector + bottomRight, Color.magenta);
            //Debug.DrawLine(debugVector + topLeft, debugVector + bottomLeft, Color.magenta);
            //Debug.DrawLine(debugVector + bottomRight, debugVector + bottomLeft, Color.magenta);
            DrawRectangle(bottomLeft, topRight, attackSpotCenter, Quaternion.Euler(0f, 0f, angle), Color.magenta);
            Collider2D[] array = Physics2D.OverlapBoxAll(attackSpotCenter, attackSpot.Range, angle, LayerMask.GetMask("HurtBox"));
            foreach (Collider2D collider2D in array)
            {
                if (!(collider2D.transform.parent.gameObject != _m.gameObject) || _m.isMaxHit(new HittedGameObjectKey(currentAttackSpot, collider2D.transform.parent.gameObject), attackSpot.HitMax)) 
                {
                    continue;
                }
                bool num = collider2D.transform.parent.TryGetComponent<IHitable>(out var IHitable) && IHitable.TakeDamage(new Damage(_m.Attack.Final * GetDamageRatio(_m), DamageType), HitStun, _m, !collider2D.transform.parent.GetComponent<Character>().ImmuneInterruptAction && CanInterruptAction, collider2D.ClosestPoint(_m.transform.position + vector));
                _m.RegisterHit(new HittedGameObjectKey(currentAttackSpot, collider2D.transform.parent.gameObject));
                if (num)
                {
                    _m.AttackLand();
                    //CameraManager.i.GenerateImpulse(DamageRatio);
                    if (collider2D.transform.parent.gameObject.CompareTag("Breakable"))
                    {
                        return;
                    }
                    Character component = collider2D.transform.parent.GetComponent<Character>();
                    HitSuccess(_m, component, IHitable, collider2D.ClosestPoint(_m.transform.position + vector));
                    float y = 0f;
                    if (SuckEffect)
                    {
                        y = _m.transform.position.y - component.transform.position.y;
                    }
                    component.TakeForce(Vector3Utility.CacuFacing(_m.NowAction.ApplyForce, ForceBasedByPos ? Vector3Utility.GetFacingByPos(_m.transform, component.transform) : _m.Facing), new Vector2(0f, y));
                    _ = (component.transform.position - _m.transform.position).normalized;
                }
            }
            //Debug.Log("attacking");
        }
        TryRegisterMove(_m, actionState.YinputWhenAction);
        //oldLinks
        if (actionState.ActionTime >= 1f)
        {

            EndAction(_m);
        }
    }

    public virtual void TryRegisterMove(Character _m, float _verticalPower = 0f)
    {
        ActionPeformState actionState = _m.ActionState;
        if (actionState.CurrMoveIndex < _m.NowAction.Moves.Count && actionState.IsAfterFrame(_m.NowAction.Moves[actionState.CurrMoveIndex].KeyFrame))
        {
            _m.StoredMoves.Add(new ForceMovement(_m.NowAction.Moves[actionState.CurrMoveIndex], new Vector3(0f, _verticalPower), _m.transform.position));
            actionState.CurrMoveIndex++;
        }
    }

    public virtual void PlaySoundEffect()
    {
        if (soundEffectName != "" && soundEffectName != null)
            SoundManager.i.PlaySound(soundEffectName);
    }

    private void DrawRectangle(Vector2 point1, Vector2 point2, Vector3 origin, Quaternion orientation, Color color)
    {
        // Calculate extent as a distance between point1 and point2
        float extentX = Mathf.Abs(point1.x - point2.x);
        float extentY = Mathf.Abs(point1.y - point2.y);

        // Calculate rotated axes
        Vector3 rotatedRight = orientation * Vector3.right;
        Vector3 rotatedUp = orientation * Vector3.up;

        // Calculate each rectangle point
        Vector3 pointA = origin + rotatedRight * point1.x + rotatedUp * point1.y;
        Vector3 pointB = pointA + rotatedRight * extentX;
        Vector3 pointC = pointB + rotatedUp * extentY;
        Vector3 pointD = pointA + rotatedUp * extentY;

        // Draw lines between the points
        DrawLine(pointA, pointB, color);
        DrawLine(pointB, pointC, color);
        DrawLine(pointC, pointD, color);
        DrawLine(pointD, pointA, color);
    }

    private void DrawLine(Vector3 a, Vector3 b, Color color)
    {
        Debug.DrawLine(a, b, color);
    }
}


[Serializable]
public class AttackTiming
{
    public int KeyFrameFrom;

    public int KeyFrameEnd;

    public Vector3 Offset;

    public Vector2 Range;

    public float Angle;

    [Header("本次攻擊擊中敵人次數上限")]
    public int HitMax;

    [Header("紅眼提示")]
    public bool SpawnOmen;
    public int SpawnKeyFrame;
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

