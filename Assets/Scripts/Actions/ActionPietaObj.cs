using FunkyCode.SuperTilemapEditorSupport.Light.Shadow;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UIElements.Experimental;

[CreateAssetMenu(fileName = "ActionPieta", menuName = "Actions/Pieta")]
public class ActionPietaObj : ActionBaseObj
{
    [Header("ActionPieta")]

    public GameObject PietaEffect;

    public GameObject SliceEffect;

    private float damageFactor;

    public override void Init(Character _m)
    {
        foreach (ActionMovement movement in _m.NowAction.Moves)
        {
            if (movement.CanEvade)
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

        base.IsTriggered = new bool[_m.NowAction.Toggles.Count];
        base.IsTeleported = new bool[_m.NowAction.Teleports.Count];
    }

    public override ActionPeformState StartAction(Character _m)
    {
        Instantiate(PietaEffect, _m.transform.position, _m.Facing == 1 ? Quaternion.identity : Quaternion.Euler(Vector3.forward * 180), _m.transform);

        _m.Player.EvadeState.EvadeReady(false);
        _m.Player.EvadeState.UseEvade(_m);

        damageFactor = _m.Player.Morph.GetMorphLevelDamageFactor();
        _m.Player.Morph.Consume(1f, true);

        //增加距離至安全位置
        float endPosSafeZoneRadius = 2f;

        Vector3 endPos = new Vector3(Pieta.i.FarestTargetCollider2D.bounds.center.x, _m.transform.position.y) + Vector3Utli.CacuFacing(new Vector3(Pieta.i.FarestTargetCollider2D.bounds.extents.x, 0f) + Vector3.right * endPosSafeZoneRadius, _m.Facing);
        Collider2D[] array = Physics2D.OverlapBoxAll(endPos, _m.Collider.bounds.size + Vector3.right * 1.5f * endPosSafeZoneRadius, 0f, LayerMask.GetMask("Character"));

        float longestDis = 0;
        int debug = 0;
        while (array.Length > 0 && debug < 50)
        {
            //Debug.Log("while");
            debug++;
            if (debug == 50)
            {
                Debug.LogError("無限迴圈");
                Debug.LogError(array.Length);
                Debug.LogError(array[0].name);
            }


            array = Physics2D.OverlapBoxAll(endPos, _m.Collider.bounds.size + Vector3.right * 1.5f * endPosSafeZoneRadius, 0f, LayerMask.GetMask("Character"));
            foreach (Collider2D collider2D in array)
            {
                float newDis = Vector2.Distance(_m.transform.position, collider2D.transform.position);
                if (longestDis < newDis && collider2D.gameObject != _m.gameObject)
                {
                    longestDis = newDis;
                    endPos = new Vector3(collider2D.bounds.center.x, _m.transform.position.y) + Vector3Utli.CacuFacing(new Vector3(collider2D.bounds.extents.x, 0) + Vector3.right * endPosSafeZoneRadius, _m.Facing);
                }
            }
            
        }

        //新增可聖殤目標至安全位置
        float dis = Vector3.Distance(_m.transform.position, endPos);
        RaycastHit2D[] ray = Pieta.i.CanPietaRange(dis);

        Pieta.i.CanPietaList.Clear();
        foreach (RaycastHit2D hit in ray)
        {
            if (hit.collider != _m.Collider)
            {
                PietaTarget pietaTarget = new PietaTarget(hit.collider);
                pietaTarget.SlicePos = pietaTarget.Collider2D.transform.position;
                Pieta.i.CanPietaList.Add(pietaTarget);
            }
        }

        //聖殤結束位置
        Pieta.i.PietaEndDis = new Vector2(Mathf.Abs(endPos.x - _m.transform.position.x), Mathf.Abs(endPos.y - _m.transform.position.y));


        return base.StartAction(_m);
    }

    public override void ProcessAction(Character _m)
    {
        List<PietaTarget> triggeredTargetList = new List<PietaTarget>();
        //foreach (PietaTarget pietaTarget in Pieta.i.CanPietaList)經過就觸發
        //{
        //    if (_m.Facing * (pietaTarget.SlicePos.x - _m.transform.position.x) <= 0f) 
        //    {
        //        triggeredTargetList.Add(pietaTarget);
        //        Vector3 hitPoint = new Vector3(pietaTarget.Collider2D.transform.position.x, _m.transform.position.y + .5f);
        //        Transform slice = Instantiate(SliceEffect, hitPoint, _m.Facing == 1 ? Quaternion.identity : Quaternion.Euler(Vector3.up * 180), pietaTarget.Collider2D.transform).transform;
        //        slice.localScale *= pietaTarget.Collider2D.GetComponent<Character>().SliceMultiply;
        //
        //        //造成傷害
        //        bool num = pietaTarget.Collider2D.TryGetComponent<IHitable>(out var IHitable) && IHitable.TakeDamage(new Damage(_m.Attack.Final * GetDamageRatio(_m), DamageType), HitStun, _m, !pietaTarget.Collider2D.GetComponent<Character>().ImmuneInterruptAction && CanInterruptAction);
        //        _m.RegisterHit(pietaTarget.Collider2D.gameObject);
        //        if (num)
        //        {
        //            _m.AttackLand();
        //            //CameraManager.i.GenerateImpulse(DamageRatio);
        //            if (pietaTarget.Collider2D.gameObject.CompareTag("Breakable"))
        //            {
        //                return;
        //            }
        //            Character component = pietaTarget.Collider2D.GetComponent<Character>();
        //            HitSuccess(_m, component, IHitable, hitPoint);
        //            float y = 0f;
        //            if (SuckEffect)
        //            {
        //                y = _m.transform.position.y - component.transform.position.y;
        //            }
        //            component.TakeForce(Vector3Utli.CacuFacing(_m.NowAction.ApplyForce, ForceBasedByPos ? Vector3Utli.GetFacingByPos(_m.transform, component.transform) : _m.Facing), new Vector2(0f, y));
        //            _ = (component.transform.position - _m.transform.position).normalized;
        //        }
        //    }
        //}
        if (Pieta.i.CanPietaList.Count > 0 && _m.Facing * (Pieta.i.CanPietaList[Pieta.i.CanPietaList.Count - 1].SlicePos.x - _m.transform.position.x) <= 0f) //經過最後一隻才觸發
        {
            foreach (PietaTarget pietaTarget in Pieta.i.CanPietaList)
            {
                triggeredTargetList.Add(pietaTarget);
                Vector3 hitPoint = new Vector3(pietaTarget.Collider2D.transform.position.x, _m.transform.position.y + .5f);
                Transform slice = Instantiate(SliceEffect, hitPoint, _m.Facing == 1 ? Quaternion.Euler(new Vector3(0, 0, -10)) : Quaternion.Euler(new Vector3(0, 180, -10)), pietaTarget.Collider2D.transform).transform;
                slice.localScale *= pietaTarget.Collider2D.GetComponent<Character>().SliceMultiply;

                //造成傷害
                bool num = pietaTarget.Collider2D.TryGetComponent<IHitable>(out var IHitable) && IHitable.TakeDamage(new Damage(_m.Attack.Final * GetDamageRatio(_m) * damageFactor, DamageType), HitStun, _m, !pietaTarget.Collider2D.GetComponent<Character>().ImmuneInterruptAction && CanInterruptAction);
                _m.RegisterHit(new HittedGameObjectKey(0, pietaTarget.Collider2D.gameObject));
                if (num)
                {
                    _m.AttackLand();
                    //CameraManager.i.GenerateImpulse(DamageRatio);
                    if (pietaTarget.Collider2D.gameObject.CompareTag("Breakable"))
                    {
                        return;
                    }
                    Character component = pietaTarget.Collider2D.GetComponent<Character>();
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
        

        if (triggeredTargetList.Count > 0)
        {
            foreach (PietaTarget pietaTarget in triggeredTargetList)
            {
                Pieta.i.CanPietaList.Remove(pietaTarget);
            }
        }

        base.ProcessAction(_m);

    }

    public override void TryRegisterMove(Character _m, float _verticalPower = 0)
    {
        ActionPeformState actionState = _m.ActionState;
        if (actionState.CurrMoveIndex < _m.NowAction.Moves.Count && actionState.IsAfterFrame(_m.NowAction.Moves[actionState.CurrMoveIndex].KeyFrame))
        {
            _m.StoredMoves.Add(new ForceMovement(
                new ActionMovement(_m.NowAction.Moves[actionState.CurrMoveIndex], Pieta.i.PietaEndDis),
                new Vector3(0f, _verticalPower),
                _m.transform.position));
            actionState.CurrMoveIndex++;
        }
    }

    public override void HitSuccess(Character _m, Character _hitted, IHitable IHitable, Vector2 _ClosestPoint)
    {
        Instantiate(AerutaDebug.i.BloodEffect, _ClosestPoint, Quaternion.Euler(Vector3.forward * 90 * Vector3Utli.GetFacingByPos(_m.transform, _hitted.transform) * -1), _hitted.transform);
        
        AerutaDebug.i.Feedback.PietaCount++;

        MarkManager.i.TriggerHittedMark(_m, _hitted);
    }

    public override void EndAction(Character _m)
    {
        _m.Player.EvadeState.EvadeReady(true);

        base.EndAction(_m);
    }
}
