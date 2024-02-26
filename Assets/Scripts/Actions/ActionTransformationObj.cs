using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[CreateAssetMenu(fileName = "ActionTransformation", menuName = "Actions/Transformation")]
public class ActionTransformationObj : ActionBaseObj
{
    [Header("ActionClaw")]

    public string AnimationKeySecondClip;

    public override void Init(Character _m)
    {
        Animator ani = Instantiate(AerutaDebug.i.TransformationEffect, _m.transform.position + new Vector3(-.07f, -1.29f, 0f), Quaternion.Euler(new Vector3(-10, 0, 0)), _m.transform).GetComponentInChildren<Animator>();
        ani.Play(Id);
        ani.Update(0f);

        base.Init(_m);
    }

    public override ActionPeformState StartAction(Character _m)
    {
        _m.Player.InvincibleState.Invincible(.8f, false);

        return base.StartAction(_m);
    }

    public override void ProcessAction(Character _m)
    {
        ActionPeformState actionState = _m.ActionState;
        actionState.SetTime(_m.Ani.GetCurrentAnimatorStateInfo(0).normalizedTime);

        if (actionState.ActionTime >= 1f && _m.Ani.GetCurrentAnimatorStateInfo(0).fullPathHash != Animator.StringToHash("Base Layer." + AnimationKeySecondClip))
        {
            ChangeRenderer(_m);
            ChangeClip(_m);
        }

        if (_m.Ani.GetCurrentAnimatorStateInfo(0).fullPathHash == Animator.StringToHash("Base Layer." + AnimationKeySecondClip))
        {
            ProcessSecondClipAnimation(_m);
        }
        else
        {
            base.ProcessAction(_m);
        }
    }

    public override void EndAction(Character _m)
    {
        base.EndAction(_m);
    }

    private void ChangeClip(Character _m)
    {
        AnimatorExtensions.RebindAndRetainParameter(_m.Ani);
        //_m.Ani.Rebind();
        _m.Ani.Play(AnimationKeySecondClip);
        _m.Ani.Update(0f);
        _m.ActionState.Clip = _m.Ani.GetCurrentAnimatorClipInfo(0)[0].clip;
        _m.ActionState.TotalFrame = Mathf.RoundToInt(_m.ActionState.Clip.length * _m.ActionState.Clip.frameRate);
    }

    private void ProcessSecondClipAnimation(Character _m)
    {
        ActionPeformState actionState = _m.ActionState;
        actionState.SetTime(_m.Ani.GetCurrentAnimatorStateInfo(0).normalizedTime + 1f);

        if (actionState.ActionTime >= 2f)
        {
            EndAction(_m);
        }
    }





    public void ChangeRenderer(Character _m)
    {
        if (_m.Player.CatMode)
        {
            //_m.Renderer.enabled = true;
            //_m.Player.CatRenderer.enabled = false;
            //_m.Ani.runtimeAnimatorController = _m.Player.HumanAni;
            _m.Renderer.gameObject.SetActive(true);
            _m.Player.CatRenderer.gameObject.SetActive(false);

            _m.Ani = _m.Renderer.GetComponent<Animator>();

            _m.Player.EvadeState.Renderer = _m.Renderer;
            _m.Player.InvincibleState.Renderer = _m.Renderer;
            _m.Player.HitEffect.Ani = _m.Ani;

            _m.Player.SwitchMode();
            _m.Player.CheckFace();
        }
        else
        {
            //_m.Renderer.enabled = false;
            //_m.Player.CatRenderer.enabled = true;
            //_m.Ani.runtimeAnimatorController = _m.Player.CatAni;
            _m.Renderer.gameObject.SetActive(false);
            _m.Player.CatRenderer.gameObject.SetActive(true);

            _m.Ani = _m.Player.CatRenderer.GetComponent<Animator>();

            _m.Player.EvadeState.Renderer = _m.Player.CatRenderer;
            _m.Player.InvincibleState.Renderer = _m.Player.CatRenderer;
            _m.Player.HitEffect.Ani = _m.Ani;

            _m.Player.SwitchMode();
            _m.Player.CheckFace();
        }
    }
}
