using System;
using UnityEngine;

[Serializable]
public class ActionMovement
{
    public int KeyFrame;

    public AnimationCurve Curve = new AnimationCurve(new Keyframe(0f, 0f), new Keyframe(1f, 1f));

    public Vector2 TargetDistance;

    public float FinishTime;

    public bool CanEvade;

    public int StartEvadeFrame;

    public int EndEvadeFrame;
}