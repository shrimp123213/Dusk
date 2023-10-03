using System;
using UnityEngine;

[Serializable]
public class ActionMovement
{
    public int KeyFrame;

    public Vector3 Power_ZTime;

    public AnimationCurve XCurve = new AnimationCurve(new Keyframe(0f, 1f), new Keyframe(1f, 1f));

    public AnimationCurve YCurve = new AnimationCurve(new Keyframe(0f, 1f), new Keyframe(1f, 1f));

    public bool CanEvade;

    public int StartEvadeFrame;

    public int EndEvadeFrame;
}