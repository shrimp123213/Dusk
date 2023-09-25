using UnityEngine;
using static TMPro.SpriteAssetUtilities.TexturePacker_JsonArray;

public class ActionPeformState
{
    public float ActionTime;

    public int CurrAttackTiming;

    public bool TryedLink;

    public bool Linked;

    public int CurrMoveIndex;

    public float YinputWhenAction;

    public bool Bool1;

    public int Frame;

    public int TotalFrame;

    public int LastFrame = -1;

    public int LastFrameVirtual = -1;

    public AnimationClip Clip;

    public void SetTime(float _actionTime)
    {
        ActionTime = _actionTime;
        Frame = Mathf.RoundToInt((float)TotalFrame * ActionTime);
    }

    public bool CanDoThingsThisUpdateVirtual()
    {
        if (Frame > LastFrameVirtual)
        {
            LastFrameVirtual = Frame;
            return true;
        }
        return false;
    }

    public bool CanDoThingsThisUpdate()
    {
        if (Frame > LastFrame)
        {
            LastFrame = Frame;
            return true;
        }
        return false;
    }

    public bool IsAfterFrame(int _frame)
    {
        return (double)ActionTime > (double)_frame / (double)TotalFrame;
    }

    public bool IsInLifeTime(float _lifeTime)
    {
        if (_lifeTime == -1)
        {
            return true;
        }
        else
        {
            return ActionTime < _lifeTime;
        }
    }

    public bool IsWithinFrame(int Start, int End)
    {
        if (Frame >= Start)
        {
            return Frame <= End;
        }
        return false;
    }

    public bool IsInFrame(int _frame)
    {
        return Frame == _frame;
    }
}