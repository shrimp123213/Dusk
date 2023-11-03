using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[CreateAssetMenu(fileName = "ActionPenetrate", menuName = "Actions/Penetrate")]
public class ActionPenetrateObj : ActionBaseObj
{
    private GameObject trail;

    private bool trailColorChanged;

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
                Afterimage.EulerAngles = new Vector3(0, 0, 40 * _m.Facing);
                Afterimage.IsSprite = _m.GetComponentInChildren<MeshRenderer>().enabled ? false : true;
                Afterimage.SetLifeTime(StartDelay, Duration);
            }

            trail = Instantiate(AerutaDebug.i.PenetrateTrail, _m.transform.position, Quaternion.identity, _m.transform);
            trail.SetActive(false);
        }

        base.IsTriggered = new bool[_m.NowAction.Toggles.Count];
        base.IsTeleported = new bool[_m.NowAction.Teleports.Count];
        
    }

    public override ActionPeformState StartAction(Character _m)
    {
        AerutaDebug.i.Leaf.Pause();

        AerutaDebug.i.Boss1.Ani.speed = 0f;
        AerutaDebug.i.Boss1.AITree.enabled = false;

        AerutaDebug.i.Feedback.UltimateCount++;

        trailColorChanged = false;

        return base.StartAction(_m);
    }

    public override void ProcessAction(Character _m)
    {
        ActionPeformState actionState = _m.ActionState;
        foreach (ActionMovement movement in _m.NowAction.Moves)
        {
            if (actionState.IsAfterFrame(movement.KeyFrame) && trail != null)
            {
                trail.SetActive(true);
                break;
            }
        }
        foreach (AttackTiming attackSpot in _m.NowAction.AttackSpots)
        {
            
            if (actionState.IsAfterFrame(attackSpot.KeyFrameFrom) && trail != null && !trailColorChanged)
            {
                trailColorChanged = true;

                trail.GetComponent<TrailRenderer>().startColor = Color.white;
                trail.GetComponent<TrailRenderer>().endColor = Color.white;

                AerutaDebug.i.Leaf.Play();

                AerutaDebug.i.Boss1.Ani.speed = 1f;
                AerutaDebug.i.Boss1.AITree.enabled = true;

                break;
            }
            if (actionState.IsAfterFrame(attackSpot.KeyFrameEnd) && trail != null)
            {
                Destroy(trail);
            }
        }

        base.ProcessAction(_m);

    }

    public override void HitSuccess(Character _m, Character _hitted, IHitable IHitable, Vector2 _ClosestPoint)
    {
        base.HitSuccess(_m, _hitted, IHitable, _ClosestPoint);

    }
}
