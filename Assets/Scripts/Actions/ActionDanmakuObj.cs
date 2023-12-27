using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[CreateAssetMenu(fileName = "ActionDanmaku", menuName = "Actions/Danmaku")]
public class ActionDanmakuObj : ActionBaseObj
{
    [Header("彈幕設定")]
    public DanmakuBaseObj danmaku;
    
    public int shootKey;
    
    private bool shooted = false;
    
    public override ActionPeformState StartAction(Character _m)
    {
        shooted = false;
        return base.StartAction(_m);
    }
    
    public override void ProcessAction(Character _m)
    {
        base.ProcessAction(_m);
        ActionPeformState actionState = _m.ActionState;
        if (actionState.IsAfterFrame(this.shootKey) && !shooted)
        {
            shooted = true;
            Debug.Log(string.Concat(new object[]
            {
                "Fire in ",
                this.shootKey,
                "/",
                actionState.Frame,
                "/",
                actionState.LastFrame
            }));
            _m.StartCoroutine(this.SpawnBullet(_m));
        }
    }

    //public void BulletCheckHit(Character _m, Collider2D collider2D)
    //{
    //    if (!(collider2D.transform.parent.gameObject != _m.gameObject) || _m.isMaxHit(new HittedGameObjectKey(currentAttackSpot, collider2D.transform.parent.gameObject), attackSpot.HitMax))
    //    {
    //        continue;
    //    }
    //    bool num = collider2D.transform.parent.TryGetComponent<IHitable>(out var IHitable) && IHitable.TakeDamage(new Damage(_m.Attack.Final * GetDamageRatio(_m), DamageType), HitStun, _m, !collider2D.transform.parent.GetComponent<Character>().ImmuneInterruptAction && CanInterruptAction, collider2D.ClosestPoint(_m.transform.position + vector));
    //    _m.RegisterHit(new HittedGameObjectKey(currentAttackSpot, collider2D.transform.parent.gameObject));
    //    if (num)
    //    {
    //        _m.AttackLand();
    //        //CameraManager.i.GenerateImpulse(DamageRatio);
    //        if (collider2D.transform.parent.gameObject.CompareTag("Breakable"))
    //        {
    //            return;
    //        }
    //        Character component = collider2D.transform.parent.GetComponent<Character>();
    //        HitSuccess(_m, component, IHitable, collider2D.ClosestPoint(_m.transform.position + vector));
    //        float y = 0f;
    //        if (SuckEffect)
    //        {
    //            y = _m.transform.position.y - component.transform.position.y;
    //        }
    //        component.TakeForce(Vector3Utility.CacuFacing(_m.NowAction.ApplyForce, ForceBasedByPos ? Vector3Utility.GetFacingByPos(_m.transform, component.transform) : _m.Facing), new Vector2(0f, y));
    //        _ = (component.transform.position - _m.transform.position).normalized;
    //    }
    //}

    private IEnumerator SpawnBullet(Character _m)
    {
        for (int i = 0; i < danmaku.shotsPerInterval; i++)
        {
            foreach (var data in danmaku.bulletSpawnData)
            {
                var rotation = _m.Facing > 0 ? data.rotation : -data.rotation;
                var damage = new Damage(_m.Attack.Final * DamageRatio,DamageType.Bullet);
                
                Instantiate<GameObject>(danmaku.bulletPrefab,danmaku.SetBulletSpawnPos(_m, data), Quaternion.Euler(0f, 0f, rotation))
                    .GetComponent<Bullet>().SetAwake(_m, damage, danmaku);
                
                yield return new WaitForSeconds(danmaku.timeBetweenShots);
            }
            
            /*switch (bulletSpawnData.spawnType)
            {
                case SpawnType.Base:
                    Instantiate<GameObject>(danmakuBaseObj.bulletPrefab, _m.transform.position, Quaternion.identity);//.GetComponent<Bullet>().SetDirection(new Vector2(0f, -1f));
                    break;
                case SpawnType.Global:
                    Instantiate<GameObject>(danmakuBaseObj.bulletPrefab, bulletSpawnData.position, Quaternion.identity);//.GetComponent<Bullet>().SetDirection(new Vector2(0f, -1f));
                    break;
                case SpawnType.Screen:
                    Instantiate<GameObject>(danmakuBaseObj.bulletPrefab, Camera.main.ScreenToWorldPoint(bulletSpawnData.position), Quaternion.identity);//.GetComponent<Bullet>().SetDirection(new Vector2(0f, -1f));
                    break;*/
            
        }
    }
    
    
}
