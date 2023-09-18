using System.Collections;
using System.Collections.Generic;
using Unity.Collections;
using UnityEngine;

public class Character : MonoBehaviour
{
    [SerializeField, ReadOnly] private CharacterStates _currentCharacterStates = CharacterStates.Idle;

    public CharacterStates CurrentCharacterStates
    {
        get => _currentCharacterStates;
        private set => _currentCharacterStates = value;
    }

    public void SetCharacterStates(CharacterStates newState) => CurrentCharacterStates = newState;
}

public enum CharacterStates
{
    Idle,
    Walking,
    Jumping,

}