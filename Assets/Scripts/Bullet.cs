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
    public bool destroyOnHit = true;
    
    public string SoundEffectName;
    
    protected Collider2D Collider;
    protected Animator anim;
    [SerializeField]
    protected ParticleSystem ps;
    protected ActionDanmakuObj danmaku;
    
    public enum Type
    {
        Bullet,
        GSpear,
        Laser
    }
    public Type TypeOfBullet;
    
    [SerializeField]
    protected bool Dead = false;
    
    public bool Awaked = false;
    
    protected bool IsSoundPlayed;

    private void Awake()
    {
        OnAwake();
    }

    public virtual void OnAwake()
    {
        Rigid = GetComponent<Rigidbody2D>();
        Collider = GetComponent<Collider2D>();
        anim = GetComponent<Animator>();
        ps = GetComponent<ParticleSystem>();
        IsSoundPlayed = false;
    }
    
    public virtual void SetAwake(Character _owner, float _delay, Damage _damage, DanmakuBaseObj _danmakuData)
    {
        Owner = _owner;
        Damage = _damage;
        Speed = _danmakuData.bulletSpeed * Owner.Facing;
        danmaku = Owner.NowAction as ActionDanmakuObj;
        
        transform.localScale = new Vector3(transform.localScale.x * Owner.Facing, transform.localScale.y, transform.localScale.z);
        
        Destroy(gameObject, LifeTime);
        foreach (var data in _danmakuData.bulletSpawnData)
        {
            StartCoroutine(ButtleStartUp(_delay));
            
        }
        /*if(ps != null)
            ps.Play();*/
    }
    
    private void FixedUpdate()
    {
        OnFixedUpdate();
    }
    
    public virtual void OnFixedUpdate()
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
            case Type.Laser:
                break;
        }
    }

    public virtual void Death()
    {
        if(Dead)
            return;
        
        Dead = true;
        Awaked = false;
        //Rigid.velocity = Vector2.zero;
        Collider.enabled = false;
        if(destroyOnHit)
            Destroy(gameObject);
    }
    
    public virtual void PlaySoundEffect(string _soundName)
    {
        if(!string.IsNullOrEmpty(SoundEffectName))
            SoundManager.i.PlaySound(_soundName);
    }
    
    private IEnumerator ButtleStartUp(float _delay)
    {
        Debug.Log("Fire in " + _delay + "s");
        yield return new WaitForSeconds(_delay);
        Awaked = true;
        anim.Play("Action");
        PlaySoundEffect(SoundEffectName);
        /*if (!IsSoundPlayed)
        {
            
            IsSoundPlayed = true;
        }*/
        yield break;
    }
    
    private void OnTriggerEnter2D(Collider2D other)
    {
        if (Awaked && other.transform.parent.CompareTag("Player"))
        {
            //if (danmaku != null) danmaku.BulletCheckHit(Owner, other);
            
            //Death();
            bool num = other.transform.parent.TryGetComponent<IHitable>(out var IHitable) && IHitable.TakeDamage(Damage, 0.25f, Owner, !other.transform.parent.GetComponent<Character>().ImmuneInterruptAction, other.ClosestPoint(transform.position));

            /*if (num)
                Death();*/
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
