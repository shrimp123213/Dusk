using System.Collections.Generic;
using UnityEditor;
using UnityEngine;
using UnityEngine.UIElements.Experimental;

public class ForceMovement
{
    public ActionMovement Base;

    public float TimeUsed;

    public Vector3 ExternalPower;

    public ForceMovement(ActionMovement _base, Vector3 _externalPower)
    {
        Base = _base;
        TimeUsed = 0f;
        ExternalPower = _externalPower;
    }
}
