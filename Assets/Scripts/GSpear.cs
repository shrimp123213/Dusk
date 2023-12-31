using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class GSpear : Bullet
{
    public override void SetAwake(Character _owner, float _delay, Damage _damage, DanmakuBaseObj _danmakuData)
    {
        Owner = _owner;
        Damage = _damage;
        
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
        yield break;
    }
    

}
