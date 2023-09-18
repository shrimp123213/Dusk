using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Events;
using System.Linq;

public class ActionHolder : MonoBehaviour
{
    public Character Owner;

    public BaseAction Action;

    public enum ActionStates
    {
        Ready = 0,
        Casting = 1,
        Cooldown = 2,
    }
    public ActionStates CurrentActionStates = ActionStates.Ready;

    private Coroutine _handleActionUsage;

    public UnityEvent OnTriggerAction;

    public void TriggerAction()
    {
        if (CurrentActionStates != ActionStates.Ready)
            return;

        if (!CharacterIsOnAllowedStates())
            return;

        _handleActionUsage = StartCoroutine(HandleActionUsage_CO());
    }

    public bool CharacterIsOnAllowedStates()
    {
        return Action.AllowedCharacterStates.Contains(Owner.CurrentCharacterStates);
    }

    private IEnumerator HandleActionUsage_CO()
    {
        CurrentActionStates = ActionStates.Casting;

        yield return new WaitForSeconds(Action.CastingTime);

        Action.Activate(this);

        CurrentActionStates = ActionStates.Cooldown;

        OnTriggerAction?.Invoke();

        if (Action.HasCooldown)
        {
            StartCoroutine(HandleCooldown_CO());
        }
    }

    private IEnumerator HandleCooldown_CO()
    {
        yield return new WaitForSeconds(Action.Cooldown);

        CurrentActionStates = ActionStates.Ready;
    }
}
