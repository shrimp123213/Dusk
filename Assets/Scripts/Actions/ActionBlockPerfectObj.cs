using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[CreateAssetMenu(fileName = "ActionBlockPerfect", menuName = "Actions/BlockPerfect")]
public class ActionBlockPerfectObj : ActionBaseObj
{
    
    public override ActionPeformState StartAction(Character _m)
    {
        Camcam.i.FocusPlayer = true;
        PlayerMain.i.isPerfectBlock = true;
        _m.Player.InvincibleState.Invincible(.2f, false);
        return base.StartAction(_m);
    }

    public override void EndAction(Character _m)
    {
        Camcam.i.FocusPlayer = false;
        PlayerMain.i.isPerfectBlock = false;
        base.EndAction(_m);
    }
}
