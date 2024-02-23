using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[CreateAssetMenu(fileName = "ActionTriggerMark", menuName = "Actions/TriggerMark")]
public class ActionTriggerMarkObj : ActionBaseObj
{
    [Header("ActionTriggerMark")]

    public GameObject SliceEffectWaitTrigger;

    private float Interval;
    public float IntervalMax;

    public override ActionPeformState StartAction(Character _m)
    {
        _m.HitEffect.SetGlobalSlow(99999f, 1);

        _m.Player.InvincibleState.Invincible(99999f, false);



        return base.StartAction(_m);
    }

    private void SpawnSliceEffect()
    {
        if (Interval > 0)
            Interval -= Time.unscaledDeltaTime;

        if (Interval <= 0f)
        {
            Interval = IntervalMax;


        }
    }

    private void PauseEffectWhenFullSlice()
    {

    }

    private void StartAllEffect()
    {

    }

    public override void EndAction(Character _m)
    {
        _m.HitEffect.SetGlobalSlow(0f, 1);

        _m.Player.InvincibleState.Invincible(0f, true);

        base.EndAction(_m);
    }
}
