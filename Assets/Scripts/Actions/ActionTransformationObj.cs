using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[CreateAssetMenu(fileName = "ActionTransformation", menuName = "Actions/Transformation")]
public class ActionTransformationObj : ActionBaseObj
{
    private bool startMode;

    public override void Init(Character _m)
    {
        Animator ani = Instantiate(AerutaDebug.i.TransformationEffect, _m.transform.position - Vector3.up, Quaternion.Euler(new Vector3(-10, 0, 0)), _m.transform).GetComponentInChildren<Animator>();
        ani.Play(_AnimationKey);
        ani.Update(0f);

        base.Init(_m);
    }

    public override ActionPeformState StartAction(Character _m)
    {
        startMode = _m.Player.CatMode;

        if (startMode == true)
            _m.Player.SwitchMode();

        return base.StartAction(_m);
    }

    public override void EndAction(Character _m)
    {
        if (startMode == false)
            _m.Player.SwitchMode();

        base.EndAction(_m);
    }
}
