using System.Collections.Generic;
using UnityEngine;

public class ActionLoader : MonoBehaviour
{
    public static ActionLoader i;

    public Dictionary<string, ActionBaseObj> Actions = new Dictionary<string, ActionBaseObj>();

    private void Awake()
    {
        ActionLoader.i = this;
        ActionBaseObj[] array = Resources.LoadAll<ActionBaseObj>("");
        foreach (ActionBaseObj actionBaseObj in array)
        {
            Actions.Add(actionBaseObj.Id, actionBaseObj);
            //Debug.Log("Add");
        }
    }
}
