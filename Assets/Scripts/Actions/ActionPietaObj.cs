using FunkyCode.SuperTilemapEditorSupport.Light.Shadow;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[CreateAssetMenu(fileName = "ActionPieta", menuName = "Actions/Pieta")]
public class ActionPietaObj : ActionBaseObj
{
    public GameObject PietaEffect;

    public GameObject SliceEffect;

    public override void Init(Character _m)
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
                Afterimage.IsSprite = _m.GetComponentInChildren<MeshRenderer>().enabled ? false : true; 
                Afterimage.SetLifeTime(StartDelay, Duration);
            }
        }

        base.IsTriggered = new bool[_m.NowAction.Toggles.Count];
        base.IsTeleported = new bool[_m.NowAction.Teleports.Count];
    }

    public override ActionPeformState StartAction(Character _m)
    {
        AerutaDebug.i.Feedback.UltimateCount++;

        Instantiate(PietaEffect, _m.transform.position, _m.Facing == 1 ? Quaternion.identity : Quaternion.Euler(Vector3.forward * 180), _m.transform);

        _m.Player.EvadeState.EvadeReady(false);
        _m.Player.EvadeState.UseEvade(_m);

        return base.StartAction(_m);
    }

    public override void ProcessAction(Character _m)
    {
        List<MarkedTarget> triggeredTargetList = new List<MarkedTarget>();
        foreach (MarkedTarget markedTarget in Pieta.i.CanPietaList)
        {
            if (_m.Facing * (markedTarget.SlicePos.x - _m.transform.position.x) <= 0f) 
            {
                triggeredTargetList.Add(markedTarget);
                Vector3 hitPoint = new Vector3(markedTarget.Collider2D.transform.position.x, _m.transform.position.y + .5f);
                Transform slice = Instantiate(SliceEffect, hitPoint, _m.Facing == 1 ? Quaternion.identity : Quaternion.Euler(Vector3.up * 180), markedTarget.Collider2D.transform).transform;
                slice.localScale *= markedTarget.Collider2D.GetComponent<Character>().SliceMultiply;

                //³y¦¨¶Ë®`
                bool num = markedTarget.Collider2D.TryGetComponent<IHitable>(out var IHitable) && IHitable.TakeDamage(new Damage(_m.Attack.Final * GetDamageRatio(_m), DamageType), HitStun, _m, !markedTarget.Collider2D.GetComponent<Character>().ImmuneInterruptAction && CanInterruptAction);
                _m.RegisterHit(markedTarget.Collider2D.gameObject);
                if (num)
                {
                    _m.AttackLand();
                    //CameraManager.i.GenerateImpulse(DamageRatio);
                    if (markedTarget.Collider2D.gameObject.CompareTag("Breakable"))
                    {
                        return;
                    }
                    Character component = markedTarget.Collider2D.GetComponent<Character>();
                    HitSuccess(_m, component, IHitable, hitPoint);
                    float y = 0f;
                    if (SuckEffect)
                    {
                        y = _m.transform.position.y - component.transform.position.y;
                    }
                    component.TakeForce(Vector3Utli.CacuFacing(_m.NowAction.ApplyForce, ForceBasedByPos ? Vector3Utli.GetFacingByPos(_m.transform, component.transform) : _m.Facing), new Vector2(0f, y));
                    _ = (component.transform.position - _m.transform.position).normalized;
                }
            }
        }

        if(triggeredTargetList.Count > 0)
        {
            foreach (MarkedTarget markedTarget in triggeredTargetList)
            {
                Pieta.i.CanPietaList.Remove(markedTarget);
            }
        }

        base.ProcessAction(_m);

    }

    public override void HitSuccess(Character _m, Character _hitted, IHitable IHitable, Vector2 _ClosestPoint)
    {
        Instantiate(AerutaDebug.i.BloodEffect, _ClosestPoint, Quaternion.Euler(Vector3.forward * 90 * Vector3Utli.GetFacingByPos(_m.transform, _hitted.transform) * -1), _hitted.transform);

    }

    public override void EndAction(Character _m)
    {
        _m.Player.EvadeState.EvadeReady(true);

        base.EndAction(_m);
    }
}
