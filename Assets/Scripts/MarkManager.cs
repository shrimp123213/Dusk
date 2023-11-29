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



    private Animator Ani;

    [SerializeField]
    private float speedStart;
    private float speed;

    [SerializeField]
    private float tolerance;
    private float targetDistance;

    private bool onTargetPos;
    private Vector3 targetPos;

    public Transform Butterfly;
    private enum targetPosState
    {
        PlayerPos,
        PlayerTransform,
        PlayerButterflyPos,
    }
    private targetPosState currentState;

    private void Awake()
    {
        i = this;
        markedTargets = new List<MarkedTarget>();

        Ani = GetComponentInChildren<Animator>();
        speed = speedStart;

        Butterfly.position = PlayerMain.i.transform.position + (Vector3)PlayerMain.i.ButterflyPos;
        Butterfly.parent = PlayerMain.i.transform;
        onTargetPos = true;
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


    private void Update()
    {
        if (!onTargetPos)
        {
            MoveToTarget();
        }
    }

    public void StartMove()
    {
        if (onTargetPos)
        {
            onTargetPos = false;
            Butterfly.parent = null;
            if (currentState == targetPosState.PlayerPos)
            {
                targetPos = PlayerMain.i.transform.position;
            }
        }
        else
        {
            if (currentState == targetPosState.PlayerPos)
            {
                speed = speedStart;
                Butterfly.parent = null;
                currentState = targetPosState.PlayerTransform;
            }
            else if (currentState == targetPosState.PlayerButterflyPos)
            {
                speed = speedStart;
                Butterfly.parent = null;
                targetPos = PlayerMain.i.transform.position;
                currentState = targetPosState.PlayerPos;
            }
        }


        

    }

    private void MoveToTarget()
    {
        if (currentState == targetPosState.PlayerTransform)
            targetPos = PlayerMain.i.transform.position;
        else if (currentState == targetPosState.PlayerButterflyPos)
            targetPos = PlayerMain.i.transform.position + (Vector3)PlayerMain.i.ButterflyPos;

        Butterfly.position = Vector2.MoveTowards(Butterfly.position, targetPos, speed * Time.deltaTime);
        //speed -= Time.deltaTime * 100;

        targetDistance = Vector3.Distance(Butterfly.position, targetPos);

        if (targetDistance < tolerance)
        {
            Butterfly.position = targetPos;

            speed = speedStart;

            if (currentState == targetPosState.PlayerPos)
            {
                onTargetPos = true;
                currentState = targetPosState.PlayerTransform;
            }
            else if (currentState == targetPosState.PlayerTransform) 
            {
                StartMove();
                Butterfly.parent = PlayerMain.i.transform;
                currentState = targetPosState.PlayerButterflyPos;
            }
            else if (currentState == targetPosState.PlayerButterflyPos)
            {
                onTargetPos = true;
                currentState = targetPosState.PlayerPos;
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