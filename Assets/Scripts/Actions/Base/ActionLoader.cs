using System.Collections.Generic;
using UnityEngine;

public class ActionLoader : MonoBehaviour
{
    public static ActionLoader i;

    public Dictionary<uint, ActionBaseObj> Actions = new Dictionary<uint, ActionBaseObj>();

    private void Awake()
    {
        ActionLoader.i = this;
        ActionBaseObj[] array = Resources.LoadAll<ActionBaseObj>("");
        foreach (ActionBaseObj actionBaseObj in array)
        {
            Actions.Add(actionBaseObj.Id, actionBaseObj);
        }
    }
}
