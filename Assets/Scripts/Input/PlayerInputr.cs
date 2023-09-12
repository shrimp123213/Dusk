using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.InputSystem;

public class PlayerInputr : MonoBehaviour
{
    void OnJump(InputValue value)
    {
        Debug.Log("Jump"+ value.isPressed.ToString());
        
    }

    void jumpUP()
    {

    }

    void jumpDOWN() { }
}
