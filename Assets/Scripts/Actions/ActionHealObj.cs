using Unity.VisualScripting;
using UnityEngine;


[CreateAssetMenu(fileName = "ActionHeal", menuName = "Actions/Heal")]
public class ActionHealObj : ActionBaseObj
{
    [Header("ActionHeal")]
    public float HealAmount;

    public int KeyFrame;

    private AfterimageGenerator Afterimage;

    private bool Healed;

    public override ActionPeformState StartAction(Character _m)
    {
        Healed = false;

        return base.StartAction(_m);
    }

    public override void ProcessAction(Character _m)
    {
        base.ProcessAction(_m);
        Debug.Log(Healed);
        ActionPeformState actionState = _m.ActionState;
        if (!Healed && actionState.IsAfterFrame(KeyFrame))
        {
            Healed = true;
            _m.TakeDamage(new Damage(-HealAmount, DamageType));
            this.Init(_m);
        }
    }

    public override void Init(Character _m)
    {
        if (Healed)
        {
            float StartDelay = 0f;
            float Duration = 1f;

            Afterimage = _m.gameObject.AddComponent<AfterimageGenerator>();
            Afterimage.EmitReset = 10f;
            Afterimage.DelayFadeTime = 0f;
            Afterimage.MoveTime = Afterimage.FadeTime;
            Afterimage.MovePosition = Vector3.up * 1.25f;
            Afterimage.ScaleTime = Afterimage.FadeTime;
            Afterimage.ScaleMultiply = 3f;
            Afterimage.SetLifeTime(StartDelay, Duration);
        }
    }

    public override void EndAction(Character _m)
    {
        base.EndAction(_m);

        Destroy(Afterimage);
    }
}
