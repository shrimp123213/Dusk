using System.Collections;
using System.Collections.Generic;
using System.ComponentModel;
using UnityEngine;
using System.Linq;
using Sirenix.Utilities;
using Unity.VisualScripting;

public class ButterflyManager : MonoBehaviour
{
    public static ButterflyManager i;

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

        Ani = GetComponentInChildren<Animator>();
        speed = speedStart;

        onTargetPos = true;
    }

    private void Start()
    {
        Butterfly.position = PlayerMain.i.transform.position + (Vector3)PlayerMain.i.ButterflyPos;
        Butterfly.parent = PlayerMain.i.transform;
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

        Vector3 lastPos = Butterfly.position;

        Butterfly.position = Vector2.MoveTowards(Butterfly.position, targetPos, speed * Time.deltaTime);
        //speed -= Time.deltaTime * 100;

        MarkCharacterBetweenMoveDistance(lastPos, Butterfly.position);

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

    private void MarkCharacterBetweenMoveDistance(Vector3 startPos, Vector3 endPos)
    {
        RaycastHit2D[] raycastHit2D = Physics2D.LinecastAll(startPos, endPos, LayerMask.GetMask("HurtBox"));

        raycastHit2D.ForEach(hit =>
        {
            Character hitCharacter = hit.transform.parent.GetComponent<Character>();
            if (hitCharacter != PlayerMain.i) MarkManager.i.MarkLevelUp(hitCharacter);
        });
    }
}
