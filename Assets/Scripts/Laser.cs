using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Laser : Bullet
{
    public LineRenderer lineRenderer;
    public float laserWidth = 2f;

    private float laserLength;
    //private bool laserHited;
    
    public override void OnAwake()
    {
        lineRenderer = GetComponent<LineRenderer>();
        
    }

    public override void SetAwake(Character _owner, float _delay, Damage _damage, DanmakuBaseObj _danmakuData)
    {
        Owner = _owner;
        Damage = _damage;
        
        transform.localScale = new Vector3(Owner.Facing, 1, 1);
        
        lineRenderer.startWidth = laserWidth;
        lineRenderer.endWidth = laserWidth;
        
        Destroy(gameObject, LifeTime);
        foreach (var data in _danmakuData.bulletSpawnData)
        {
            StartCoroutine(ButtleStartUp(_delay));
            Vector3 localColPoint = transform.InverseTransformPoint(Owner.Collider.bounds.center);
            lineRenderer.SetPosition(0,localColPoint);
        }
    }

    public override void OnFixedUpdate()
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
                RaycastHit2D[] hits = Physics2D.RaycastAll(Owner.Collider.bounds.center, transform.right * Owner.Facing, 1000,LayerMask.GetMask("Ground"));
                foreach (var hit in hits)
                {
                    lineRenderer.SetPosition(1, transform.InverseTransformPoint(hit.point));
                    //Debug.DrawLine(Owner.Collider.bounds.center, hit.point, Color.red, 1000f);
                    //Debug.Log(hit.collider.gameObject.name);
                    laserLength = lineRenderer.GetPosition(1).x;
                    break;
                }
                
                Collider2D[] array = Physics2D.OverlapBoxAll(lineRenderer.bounds.center, new Vector2(laserLength , laserWidth), 0, LayerMask.GetMask("HurtBox"));
                Debug.DrawLine(Owner.Collider.bounds.center,new Vector2(laserLength ,Owner.Collider.bounds.center.y) , Color.green, 1000f);
                foreach (Collider2D collider2D in array)
                {
                    //Debug.Log(collider2D.transform.parent.gameObject.name);
                    if (collider2D.transform.parent.gameObject != Owner.gameObject)
                    {
                        bool num = collider2D.transform.parent.TryGetComponent<IHitable>(out var IHitable) && IHitable.TakeDamage(Damage, 0.25f, Owner, !collider2D.transform.parent.GetComponent<Character>().ImmuneInterruptAction, collider2D.ClosestPoint(transform.position));
                        Debug.Log("Hit Player");
                        if (collider2D.transform.parent.TryGetComponent<Character>(out var character) && !character.Evading)
                            Death();

                    }
                    
                }
                /*RaycastHit2D[] hitsChr = Physics2D.RaycastAll(Owner.Collider.bounds.center, transform.right * Owner.Facing, 1000,LayerMask.GetMask("HurtBox"));
                foreach (var hit in hitsChr)
                {
                    //lineRenderer.SetPosition(1, transform.InverseTransformPoint(hit.point));
                    if (hit.collider.transform.parent.name != Owner.name)
                    {
                        //Debug.DrawLine(Owner.Collider.bounds.center, hit.point, Color.blue, 1000f);
                        Debug.Log(hit.collider.transform.parent.gameObject.name);
                    }

                    break;
                }*/
        
                break;
        }
    }

    public override void Death()
    {
        if(Dead)
            return;
        
        Dead = true;
        Awaked = false;
        //laserHited = false;
        
        //Collider.isTrigger = false;
        //lineRenderer.enabled = false;
        //Destroy(gameObject);
    }
    
    private IEnumerator ButtleStartUp(float _delay)
    {
        Debug.Log("Fire in " + _delay + "s");
        yield return new WaitForSeconds(_delay);
        Awaked = true;
        //anim.Play("Action");
        //Destroy(Omen);
        yield break;
    }
}
