using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Bullet : MonoBehaviour
{
    [HideInInspector]
    public Rigidbody2D Rigid;

    public string ParentActionID;

    public Character Owner;
    public Damage Damage;
    
    private float Speed;
    public float LifeTime = 3f;
    
    private bool Dead = false;
    private bool Awaked = false;

    private void Awake()
    {
        Rigid = GetComponent<Rigidbody2D>();
    }
    
    public void SetAwake(Character _owner, Damage _damage, DanmakuBaseObj _danmakuData)
    {
        Owner = _owner;
        Damage = _damage;
        Speed = _danmakuData.bulletSpeed * Owner.Facing;
        
        Destroy(gameObject, LifeTime);
        
        StartCoroutine(ButtleStartUp(_danmakuData.timeBetweenShots));
    }
    
    private void FixedUpdate()
    {
        if(!Awaked)
            return;
        
        Rigid.velocity = transform.right * Speed;
    }

    private void Death()
    {
        if(Dead)
            return;
        
        Dead = true;
        Awaked = false;
        Rigid.velocity = Vector2.zero;
        GetComponent<CapsuleCollider2D>().isTrigger = false;
        Destroy(gameObject);
    }
    
    private void OnTriggerEnter2D(Collider2D other)
    {
        if (Awaked && other.transform.parent.CompareTag("Player"))
        {
            bool num = other.transform.parent.TryGetComponent<IHitable>(out var IHitable) && IHitable.TakeDamage(Damage, 0f, Owner, !other.transform.parent.GetComponent<Character>().ImmuneInterruptAction, other.ClosestPoint(transform.position));

            //if (num)
                Death();
        }
    }

    private void OnTriggerStay2D(Collider2D other)
    {
        if (Awaked && other.transform.parent.CompareTag("Player"))
        {
            bool num = other.transform.parent.TryGetComponent<IHitable>(out var IHitable) && IHitable.TakeDamage(Damage, 0f, Owner, !other.transform.parent.GetComponent<Character>().ImmuneInterruptAction, other.ClosestPoint(transform.position));

            //if (num)
            Death();
        }
    }

    private IEnumerator ButtleStartUp(float _delay)
    {
        yield return new WaitForSeconds(0);
        Awaked = true;
        yield break;
    }
}
