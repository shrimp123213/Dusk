using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class GSpear : Bullet
{
    public GameObject Omen;
    public float offsetY = -7;
    
    public override void OnAwake()
    {
        Collider = GetComponent<Collider2D>();
        anim = GetComponent<Animator>();
        ps = GetComponent<ParticleSystem>();
        IsSoundPlayed = false;
    }
    
    public override void SetAwake(Character _owner, float _delay, Damage _damage, DanmakuBaseObj _danmakuData)
    {
        Owner = _owner;
        Damage = _damage;
        LifeTime += _delay;
        Destroy(gameObject, LifeTime+_delay);
        foreach (var data in _danmakuData.bulletSpawnData)
        {
            StartCoroutine(ButtleStartUp(_delay));
        }
        StartCoroutine(SpawnOmen(_delay-0.5f));
        
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
        Collider.enabled = false;
        if(destroyOnHit)
            Destroy(gameObject);
    }
    
    private IEnumerator ButtleStartUp(float _delay)
    {
        //Debug.Log("Fire in " + _delay + "s");
        yield return new WaitForSeconds(_delay);
        Awaked = true;
        anim.Play("Action");
        PlaySoundEffect(SoundEffectName);
        //Destroy(Omen);
        yield break;
    }
    
    private IEnumerator SpawnOmen(float _delay)
    {
        yield return new WaitForSeconds(_delay);
        GameObject omen = Instantiate(Omen, new Vector3(transform.position.x, offsetY, 0), Quaternion.Euler(0, 0, 0));
        yield break;
    }

}
