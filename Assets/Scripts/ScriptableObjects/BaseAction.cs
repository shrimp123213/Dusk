using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public abstract class BaseAction : ScriptableObject
{
    public uint Id;
    public bool HasCooldown = true;
    public float Cooldown = 1f;
    public float CastingTime = 0f;

    public List<CharacterStates> AllowedCharacterStates = new
        List<CharacterStates>() { CharacterStates.Idle };

    public List<Link> Links = new List<Link>();

    public virtual void OnActionUpdate(ActionHolder holder) { }

    public abstract void Activate(ActionHolder holder);
}

[System.Serializable]
public class Link
{
    public float Frame;
    public float LifeTime;
    public Keys Key1;
    public int LinkAction;
}

public enum Keys
{
    Melee,
    Range,

}
