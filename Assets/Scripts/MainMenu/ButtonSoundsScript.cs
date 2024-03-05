using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ButtonSoundsScript : MonoBehaviour
{
    public void ConfirmSound()
    {
        SoundManager.i.PlaySound("UI_Confirm");
    }
    
    public void CancelSound()
    {
        SoundManager.i.PlaySound("UI_Cancel");
    }
    
    public void SelectSound()
    {
        SoundManager.i.PlaySound("UI_Select");
        Debug.Log("Play SelectSound");
    }
}
