using Unity.VisualScripting;
using UnityEngine;


[CreateAssetMenu(fileName = "ActionHeal", menuName = "Actions/Heal")]
public class ActionHealObj : ActionBaseObj
{
    [Header("ActionHeal")]

    public float HealAmount;

    private AfterimageGenerator Afterimage;

    private float lastValue;

    public override ActionPeformState StartAction(Character _m)
    {
        lastValue = -HealAmount / 2;
        _m.TakeDamage(new Damage(lastValue, DamageType));

        return base.StartAction(_m);
    }

    public override void ProcessAction(Character _m)
    {
        base.ProcessAction(_m);

        ActionPeformState actionState = _m.ActionState;

        float currentValue = Mathf.Lerp(-HealAmount / 2, -HealAmount, actionState.ActionTime);

        _m.TakeDamage(new Damage(currentValue - lastValue, DamageType));

        lastValue = currentValue;
        
    }

    public override void Init(Character _m)
    {
        float StartDelay = 0f;
        float Duration = 1f;

        Afterimage = _m.gameObject.AddComponent<AfterimageGenerator>();
        Afterimage.IsSprite = true;
        Afterimage.EmitReset = 10f;
        Afterimage.DelayFadeTime = 0f;
        Afterimage.MoveTime = Afterimage.FadeTime;
        Afterimage.MovePosition = Vector3.up * 1.25f;
        Afterimage.ScaleTime = Afterimage.FadeTime;
        Afterimage.ScaleMultiply = 3f;
        Afterimage.SetLifeTime(StartDelay, Duration);
        IsSoundPlayed = new bool[_m.NowAction.SoundEffects.Count];

    }

    public override void EndAction(Character _m)
    {
        this.Init(_m);

        base.EndAction(_m);
    }
}
