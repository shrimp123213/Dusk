using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[CreateAssetMenu(fileName = "ActionClaw", menuName = "Actions/Claw")]
public class ActionClawObj : ActionBaseObj
{
    [Header("ActionClaw")]

    public string _AnimationKeyClawEnd;
    public string AnimationKeyClawEnd
    {
        get
        {
            if (EnableJumpVersion && !m.isGround)
                return _AnimationKeyClawEnd + "_jump";
            return _AnimationKeyClawEnd;
        }
    }

    protected Animator EffectAni;

    private bool soundPlayed;

    public GameObject Effect;
    public GameObject Effect_jump;

    public Vector3 offset;

    [Header("À»¤¤­µ®Ä")]
    public string hitSoundEffectName;

    public override ActionPeformState StartAction(Character _m)
    {
        soundPlayed = false;

        return base.StartAction(_m);
    }

    public override void ProcessAction(Character _m)
    {
        ActionPeformState actionState = _m.ActionState;
        actionState.SetTime(_m.Ani.GetCurrentAnimatorStateInfo(0).normalizedTime);

        if (actionState.ActionTime >= 1f && _m.Ani.GetCurrentAnimatorStateInfo(0).fullPathHash != Animator.StringToHash("Base Layer." + AnimationKeyClawEnd))
        {
            ChangeClip(_m);
        }

        if (_m.Ani.GetCurrentAnimatorStateInfo(0).fullPathHash == Animator.StringToHash("Base Layer." + AnimationKeyClawEnd))
        {
            ProcessClawEndAnimation(_m); 
        }
        else
        {
            base.ProcessAction(_m);
        }

        if (!soundPlayed && actionState.IsAfterFrame(_m.NowAction.AttackSpots[0].KeyFrameFrom - 1))
        {
            soundPlayed = true;
            PlaySoundEffect();
            //Debug.Log("PlaySound");
        }
    }

    public override void EndAction(Character _m)
    {
        ActionPeformState actionState = _m.ActionState;
        //actionState.SetTime(_m.Ani.GetCurrentAnimatorStateInfo(0).normalizedTime);

        if (actionState.IsBeforeFrame(_m.NowAction.AttackSpots[0].KeyFrameFrom))
        {
            if (EffectAni != null)
            {
                Destroy(EffectAni.gameObject);
                EffectAni = null;
            }
        }

        base.EndAction(_m);
    }

    private void ChangeClip(Character _m)
    {
        AnimatorExtensions.RebindAndRetainParameter(_m.Ani);
        //_m.Ani.Rebind();
        _m.Ani.Play(AnimationKeyClawEnd);
        _m.Ani.Update(0f);
        _m.ActionState.Clip = _m.Ani.GetCurrentAnimatorClipInfo(0)[0].clip;
        _m.ActionState.TotalFrame = Mathf.RoundToInt(_m.ActionState.Clip.length * _m.ActionState.Clip.frameRate);
    }

    public override void HitSuccess(Character _m, Character _hitted, IHitable IHitable, Vector2 _ClosestPoint)
    {
        base.HitSuccess(_m, _hitted, IHitable, _ClosestPoint);

        PlayHitSoundEffect();
    }

    private void ProcessClawEndAnimation(Character _m)
    {
        ActionPeformState actionState = _m.ActionState;
        actionState.SetTime(_m.Ani.GetCurrentAnimatorStateInfo(0).normalizedTime + 1f);

        if (actionState.ActionTime >= 2f)
        {
            EndAction(_m);
        }
    }

    public override void Init(Character _m)
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

        SpawnEffect(_m);
    }

    public virtual void PlayHitSoundEffect()
    {
        if (hitSoundEffectName != "")
            SoundManager.i.PlaySound(hitSoundEffectName);
    }

    public virtual void SpawnEffect(Character _m)
    {
        GameObject spawnEffect = Effect;
        if (EnableJumpVersion && !m.isGround)
            spawnEffect = Effect_jump;

        Vector3 offsetFacing = Vector3Utility.CacuFacing(offset, _m.Facing);
        EffectAni = Instantiate(spawnEffect, _m.transform.position + offsetFacing, _m.Facing == 1 ? Quaternion.Euler(Vector3.zero) : Quaternion.Euler(new Vector3(0, 180, 0)), _m.transform).GetComponent<Animator>();
        //EffectAni.Play(_AnimationKey);
        //EffectAni.Update(0f);
    }
}
