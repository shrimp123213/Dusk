using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.InputSystem;
using UniRx;
using System;
using Unity.VisualScripting;

public class PlayerInputr : MonoBehaviour
{
    public static PlayerInputr Instance { get; private set; }
    private void Awake()
    {
        // If there is an instance, and it's not me, delete myself.

        if (Instance != null && Instance != this)
        {
            Destroy(this);
        }
        else
        {
            Instance = this;
        }
    }

    //ª±®aInput
    public InputActionAsset inputActionAsset;
    private InputActionMap playerAct;

    private ReactiveCollection<InputAction> Actions = new ReactiveCollection<InputAction>();
    //public IObservable<InputAction> OnInputActionChanged => Actions;

    private void Start()
    {
        inputActionAsset = GetComponent<PlayerInput>().actions;
        playerAct = inputActionAsset.FindActionMap("Player");

        //Actions.Subscribe(x => Debug.Log(x));

        Actions.ObserveAdd()
            .Subscribe(x => Debug.Log(x));

        Actions.Add(playerAct.FindAction("Jump"));
        Actions.Add(playerAct.FindAction("Movement"));

        Actions.ObserveEveryValueChanged(x => x)
            .Subscribe(_ =>
            {
                print("Pressed");
            });


    }

}
