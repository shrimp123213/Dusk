using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using BehaviorDesigner.Runtime;

public class SharedCharacter : SharedVariable<Character>
{
    public static implicit operator SharedCharacter(Character value)
    {
        return new SharedCharacter
        {
            Value = value
        };
    }
}
