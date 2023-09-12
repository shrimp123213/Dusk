using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UniRx;
using UnityEngine.InputSystem;
using System;

public class UniRxTest : MonoBehaviour
{
    void Start()
    {
        //PlayerInputr.Instance.OnInputActionChanged
        //    .Where(x => x.WasPressedThisFrame())
        //    .Subscribe(_ =>
        //    {
        //        print("Pressed");
        //    });
        //
        //PlayerInputr.Instance.OnInputActionChanged
        //    .Where(x => x.WasReleasedThisFrame())
        //    .Subscribe(_ =>
        //    {
        //        print("Released");
        //    });

        //var doubleClick = Observable.EveryUpdate().Where(value => playerAct.FindAction("Jump").WasPressedThisFrame());
        //
        //doubleClick.Buffer(doubleClick.Throttle(TimeSpan.FromMilliseconds(250)))
        //    .Where(value => value.Count >= 2)
        //    .Subscribe(value => Debug.Log("doubleClick:" + value.Count));
    }

}
