using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class GSpear : Bullet
{
    public GameObject Omen;
    public float offsetY = -7;
    
    public override void SetAwake(Character _owner, float _delay, Damage _damage, DanmakuBaseObj _danmakuData)
    {
        Owner = _owner;
        Damage = _damage;
        
        Destroy(gameObject, LifeTime);
        foreach (var data in _danmakuData.bulletSpawnData)
        {
            StartCoroutine(ButtleStartUp(_delay));
        }
        Instantiate(Omen, new Vector3(transform.position.x, offsetY, 0), Quaternion.Euler(0, 0, 0));
        //Destroy(Omen, 0.5f);
    }
    public override void OnFixedUpdate()
    {
        base.OnFixedUpdate();
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
        //Destroy(Omen);
        yield break;
    }
    

}
