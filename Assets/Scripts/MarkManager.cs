using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System.Linq;
using System;


public class MarkManager : MonoBehaviour
{
    public static MarkManager i;

    public List<MarkedTarget> markedTargets;

    public Sprite[] MarkLevelSprites;

    public GameObject MarkTriggerEffect;


    private void Awake()
    {
        i = this;
        markedTargets = new List<MarkedTarget>();
    }

    public void MarkLevelUp(Character _hitted)
    {
        int index = markedTargets.FindIndex(i => i.Target == _hitted);
        if (index == -1)
        {
            markedTargets.Add(new MarkedTarget(_hitted));
            index = markedTargets.Count - 1;
        }

        if (markedTargets[index].MarkLevel < MarkLevelSprites.Count())
            markedTargets[index].MarkLevel++;

        markedTargets[index].Renderer.sprite = MarkLevelSprites[markedTargets[index].MarkLevel - 1];
    }

    public void ClearMarkedTargets()
    {
        markedTargets.ForEach(i => Destroy(i.Renderer.gameObject));
        markedTargets.Clear();
    }

    public void TriggerAllMark(Character _m)
    {
        markedTargets.ForEach(i => Instantiate(MarkTriggerEffect, i.Renderer.transform.position, Quaternion.identity));

        foreach (MarkedTarget markedTarget in markedTargets)
        {
            int factor = 0;
            if (markedTarget.MarkLevel == 1)
                factor = 1;
            else if(markedTarget.MarkLevel == 2)
                factor = 3;
            else if (markedTarget.MarkLevel == 3)
                factor = 6;

            bool num = markedTarget.Target.TakeDamage(new Damage(_m.Attack.Final * factor, DamageType.Normal), .25f, _m, !markedTarget.Target.ImmuneInterruptAction);
            if (num) markedTarget.Target.TakeForce(Vector2.zero, Vector2.zero);
        }

        ClearMarkedTargets();
    }

    public void TriggerHittedMark(Character _m, Character _hitted)
    {
        foreach (MarkedTarget i in markedTargets)
        {
            if (i.Target == _hitted)
            {
                Instantiate(MarkTriggerEffect, i.Renderer.transform.position, Quaternion.identity);

                int factor = 0;
                if (i.MarkLevel == 1)
                    factor = 1;
                else if (i.MarkLevel == 2)
                    factor = 3;
                else if (i.MarkLevel == 3)
                    factor = 6;

                bool num = i.Target.TakeDamage(new Damage(_m.Attack.Final * factor, DamageType.Normal), .25f, _m, !i.Target.ImmuneInterruptAction);
                if (num) i.Target.TakeForce(Vector2.zero, Vector2.zero);

                Destroy(i.Renderer.gameObject);
                markedTargets.Remove(i);

                break;
            }
        }
    }
}

public class MarkedTarget
{
    public int MarkLevel;

    public Character Target;

    public SpriteRenderer Renderer;

    public MarkedTarget(Character _hitted)
    {
        Target = _hitted;
        Renderer = new GameObject("MarkRenderer", typeof(SpriteRenderer)).GetComponent<SpriteRenderer>();
        Renderer.transform.parent = Target.transform;
        Renderer.transform.position = Target.transform.position + (Vector3)Target.MarkPos;
        Renderer.transform.eulerAngles = new Vector3(0, 0, 180);

        Renderer.sortingLayerName = "Middle2";
        Renderer.sortingOrder = 20;
    }
}