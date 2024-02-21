using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[CreateAssetMenu(fileName = "ActionTransformation", menuName = "Actions/Transformation")]
public class ActionTransformationObj : ActionBaseObj
{
    private bool startMode;

    public override void Init(Character _m)
    {
        Animator ani = Instantiate(AerutaDebug.i.TransformationEffect, _m.transform.position + new Vector3(-.07f, -1.29f, 0f), Quaternion.Euler(new Vector3(-10, 0, 0)), _m.transform).GetComponentInChildren<Animator>();
        ani.Play(Id);
        ani.Update(0f);

        base.Init(_m);
    }

    public override ActionPeformState StartAction(Character _m)
    {
        //startMode = _m.Player.CatMode;
        //
        //if (startMode == true)
        //    _m.Player.SwitchMode();

        return base.StartAction(_m);
    }

    public override void EndAction(Character _m)
    {
        ChangeRenderer(_m);
        //if (startMode == false)
        _m.Player.SwitchMode();

 

        base.EndAction(_m);
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

            _m.Player.CheckFace();
        }
    }
}
