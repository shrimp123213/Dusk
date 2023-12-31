using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class GSpear : Bullet
{
    public GameObject Omen;
    
    public override void SetAwake(Character _owner, float _delay, Damage _damage, DanmakuBaseObj _danmakuData)
    {
        Owner = _owner;
        Damage = _damage;
        
        Destroy(gameObject, LifeTime);
        foreach (var data in _danmakuData.bulletSpawnData)
        {
            StartCoroutine(ButtleStartUp(_delay));
        }
        Instantiate(Omen,transform.position,Quaternion.Euler(0,0,0));
        //Destroy(Omen, 0.5f);
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

        if (anim.GetCurrentAnimatorStateInfo(0).normalizedTime >= 1.0f)
        {
            Death();
        }
    }
    
    public override void Death()
    {
        if(Dead)
            return;
        
        Dead = true;
        Awaked = false;
        //Rigid.velocity = Vector2.zero;
        Collider.isTrigger = false;
        Destroy(gameObject);
    }
    
    private IEnumerator ButtleStartUp(float _delay)
    {
        Debug.Log("Fire in " + _delay + "s");
        yield return new WaitForSeconds(_delay);
        Awaked = true;
        anim.Play("Action");
        Destroy(Omen);
        yield break;
    }
    
    private void OnTriggerEnter2D(Collider2D other)
    {
        if (Awaked && other.transform.parent.CompareTag("Player"))
        {
            bool num = other.transform.parent.TryGetComponent<IHitable>(out var IHitable) && IHitable.TakeDamage(Damage, 0.25f, Owner, !other.transform.parent.GetComponent<Character>().ImmuneInterruptAction, other.ClosestPoint(transform.position));

            //if (num)
            if(other.TryGetComponent<Character>(out var character) && !character.Evading)
                Death();
        }
    }

    private void OnTriggerStay2D(Collider2D other)
    {
        if (Awaked && other.transform.parent.CompareTag("Player"))
        {
            bool num = other.transform.parent.TryGetComponent<IHitable>(out var IHitable) && IHitable.TakeDamage(Damage, 0.25f, Owner, !other.transform.parent.GetComponent<Character>().ImmuneInterruptAction, other.ClosestPoint(transform.position));

            //if (num)
            if(other.TryGetComponent<Character>(out var character) && !character.Evading)
                Death();
        }
    }
}
