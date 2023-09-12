using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UniRx;
using UnityEngine.InputSystem;
using System;

public class UniRxTest : MonoBehaviour
{
    //ª±®aInput
    public InputActionAsset inputActionAsset;
    private InputActionMap playerAct;

    // Start is called before the first frame update
    void Start()
    {
        inputActionAsset = GetComponent<PlayerInput>().actions;
        playerAct = inputActionAsset.FindActionMap("Player");

        var doubleClick = Observable.EveryUpdate().Where(value => playerAct.FindAction("Jump").WasPressedThisFrame());

        doubleClick.Buffer(doubleClick.Throttle(TimeSpan.FromMilliseconds(250)))
            .Where(value => value.Count >= 2)
            .Subscribe(value => Debug.Log("doubleClick:" + value.Count));
    }

}
