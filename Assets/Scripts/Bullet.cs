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
    
    protected float Speed;
    public float LifeTime = 3f;
    
    protected Collider2D Collider;
    protected Animator anim;
    
    public enum Type
    {
        Bullet,
        GSpear
    }
    public Type TypeOfBullet;
    
    [SerializeField]
    protected bool Dead = false;
    [SerializeField]
    protected bool Awaked = false;

    private void Awake()
    {
        Rigid = GetComponent<Rigidbody2D>();
        Collider = GetComponent<Collider2D>();
        anim = GetComponent<Animator>();
    }
    
    public virtual void SetAwake(Character _owner, float _delay, Damage _damage, DanmakuBaseObj _danmakuData)
    {
        Owner = _owner;
        Damage = _damage;
        Speed = _danmakuData.bulletSpeed * Owner.Facing;
        
        transform.localScale = new Vector3(Owner.Facing, 1, 1) * .6f;
        
        Destroy(gameObject, LifeTime);
        foreach (var data in _danmakuData.bulletSpawnData)
        {
            StartCoroutine(ButtleStartUp(_delay));
        }
        
    }
    
    private void FixedUpdate()
    {
        if(!Awaked)
            return;
        switch (TypeOfBullet)  
        {  
            case Type.Bullet:
                Rigid.velocity = transform.right * Speed;  
                break;  
            case Type.GSpear:
                break;
        }
    }

    public virtual void Death()
    {
        if(Dead)
            return;
        
        Dead = true;
        Awaked = false;
        Rigid.velocity = Vector2.zero;
        Collider.isTrigger = false;
        Destroy(gameObject);
    }
    
    private IEnumerator ButtleStartUp(float _delay)
    {
        Debug.Log("Fire in " + _delay + "s");
        yield return new WaitForSeconds(_delay);
        Awaked = true;
        anim.Play("Action");
        yield break;
    }
    
    private void OnTriggerEnter2D(Collider2D other)
    {
        if (Awaked && other.transform.parent.CompareTag("Player"))
        {
            bool num = other.transform.parent.TryGetComponent<IHitable>(out var IHitable) && IHitable.TakeDamage(Damage, 0.25f, Owner, !other.transform.parent.GetComponent<Character>().ImmuneInterruptAction, other.ClosestPoint(transform.position));

            //if (num)
            if(other.transform.parent.TryGetComponent<Character>(out var character) && !character.Evading)
                Death();
        }
    }

    private void OnTriggerStay2D(Collider2D other)
    {
        if (Awaked && other.transform.parent.CompareTag("Player"))
        {
            bool num = other.transform.parent.TryGetComponent<IHitable>(out var IHitable) && IHitable.TakeDamage(Damage, 0.25f, Owner, !other.transform.parent.GetComponent<Character>().ImmuneInterruptAction, other.ClosestPoint(transform.position));

            //if (num)
            if(other.transform.parent.TryGetComponent<Character>(out var character) && !character.Evading)
                Death();
        }
    }

    
}
