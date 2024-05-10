using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[CreateAssetMenu(fileName = "ActionDanmaku", menuName = "Actions/Danmaku")]
public class ActionDanmakuObj : ActionBaseObj
{
    [Header("彈幕設定")] public DanmakuBaseObj danmaku;

    //private int shootKey;

    private bool shooted = false;
    private Vector3 _mPosition;

    public override ActionPeformState StartAction(Character _m)
    {
        shooted = false;
        return base.StartAction(_m);
    }

    public override void ProcessAction(Character _m)
    {
        base.ProcessAction(_m);
        ActionPeformState actionState = _m.ActionState;
        List<BulletSpawnData> bulletSpawnData = danmaku.bulletSpawnData;
        for (int i = 0; i < bulletSpawnData.Count; i++)
        {
            var data = bulletSpawnData[i];
            shooted = false;
            if (actionState.IsAtFrame(data.shootKey))
            {
                _mPosition = _m.transform.position;
                Debug.Log(string.Concat(new object[]
                {
                    "Fire in ",
                    data.shootKey,
                    "/",
                    actionState.Frame,
                    "/",
                    actionState.LastFrame
                }));
                //_m.StartCoroutine(this.SpawnBullet(_m));

                var rotation = _m.Facing > 0 ? data.rotation : -data.rotation;
                var damage = new Damage(_m.Attack.Final * DamageRatio, DamageType.Bullet);
                var position = _mPosition;
                var scale = data.scale;
                if (scale != Vector3.zero)
                    danmaku.bulletPrefab.transform.localScale = scale;
                if (!shooted)
                {
                    GameObject bullet = Instantiate<GameObject>(danmaku.bulletPrefab,
                        danmaku.SetBulletSpawnPos(_m, position, data), Quaternion.Euler(0f, 0f, rotation));
                    bullet.GetComponent<Bullet>().SetAwake(_m, data.shotsDelay, damage, danmaku);
                    bulletSpawnData.Remove(data);
                    
                    //bullets.Add(bullet);
                    shooted = true;
                    /*Instantiate<GameObject>(danmaku.bulletPrefab,danmaku.SetBulletSpawnPos(_m, position, data), Quaternion.Euler(0f, 0f, rotation))
                    .GetComponent<Bullet>().SetAwake(_m, data.shotsDelay, damage, danmaku);
                    shooted = true;*/
                }
            }
        }

        /*foreach (var data in danmaku.bulletSpawnData)
        {
            shooted = false;
            if (actionState.IsWithinFrame(data.shootKey,data.shootKey+1) && !shooted)
            {
                shooted = true;
                _mPosition = _m.transform.position;
                Debug.Log(string.Concat(new object[]
                {
                    "Fire in ",
                    data.shootKey,
                    "/",
                    actionState.Frame,
                    "/",
                    actionState.LastFrame
                }));
                //_m.StartCoroutine(this.SpawnBullet(_m));

                var rotation = _m.Facing > 0 ? data.rotation : -data.rotation;
                var damage = new Damage(_m.Attack.Final * DamageRatio,DamageType.Bullet);
                var position = _mPosition;
                var scale = data.scale;
                if(scale != Vector3.zero)
                    danmaku.bulletPrefab.transform.localScale = scale;
                Instantiate<GameObject>(danmaku.bulletPrefab,danmaku.SetBulletSpawnPos(_m, position, data), Quaternion.Euler(0f, 0f, rotation))
                    .GetComponent<Bullet>().SetAwake(_m, data.shotsDelay, damage, danmaku);
            }
        }*/

    }

    /*public void BulletCheckHit(Character _m, Collider2D collider2D)
    {
        bool bulletHit = false;
        foreach (var bullet in bullets)
        {
            if(bullet.GetComponent<Bullet>().Awaked && collider2D.transform.parent.gameObject != _m.gameObject)
            {
                if (bulletHit)
                {
                    bullet.GetComponent<Bullet>().Death();
                    bullets.Remove(bullet);
                }
                bool num = collider2D.transform.parent.TryGetComponent<IHitable>(out var IHitable) && IHitable.TakeDamage(new Damage(_m.Attack.Final * DamageRatio, DamageType.Bullet), 0.25f, _m, !collider2D.transform.parent.GetComponent<Character>().ImmuneInterruptAction, collider2D.ClosestPoint(_m.transform.position));
                
                if (num)
                {
                    bulletHit = true;
                }
                
            }
        }
    }*/

/*public void BulletCheckHit(Character _m, Collider2D collider2D)
{
    if (!(collider2D.transform.parent.gameObject != _m.gameObject) || _m.isMaxHit(new HittedGameObjectKey(currentAttackSpot, collider2D.transform.parent.gameObject), attackSpot.HitMax))
    {
        continue;
    }
    bool num = collider2D.transform.parent.TryGetComponent<IHitable>(out var IHitable) && IHitable.TakeDamage(new Damage(_m.Attack.Final * GetDamageRatio(_m), DamageType), HitStun, _m, !collider2D.transform.parent.GetComponent<Character>().ImmuneInterruptAction && CanInterruptAction, collider2D.ClosestPoint(_m.transform.position + vector));
    _m.RegisterHit(new HittedGameObjectKey(currentAttackSpot, collider2D.transform.parent.gameObject));
    if (num)
    {
        _m.AttackLand();
        //CameraManager.i.GenerateImpulse(DamageRatio);
        if (collider2D.transform.parent.gameObject.CompareTag("Breakable"))
        {
            return;
        }
        Character component = collider2D.transform.parent.GetComponent<Character>();
        HitSuccess(_m, component, IHitable, collider2D.ClosestPoint(_m.transform.position + vector));
        float y = 0f;
        if (SuckEffect)
        {
            y = _m.transform.position.y - component.transform.position.y;
        }
        component.TakeForce(Vector3Utility.CacuFacing(_m.NowAction.ApplyForce, ForceBasedByPos ? Vector3Utility.GetFacingByPos(_m.transform, component.transform) : _m.Facing), new Vector2(0f, y));
        _ = (component.transform.position - _m.transform.position).normalized;
    }
}*/

    private IEnumerator SpawnBullet(Character _m)
    {
        for (int i = 0; i < danmaku.shotsPerInterval; i++)
        {
            foreach (var data in danmaku.bulletSpawnData)
            {
                var rotation = _m.Facing > 0 ? data.rotation : -data.rotation;
                var damage = new Damage(_m.Attack.Final * DamageRatio,DamageType.Bullet);
                var position = _mPosition;
                var scale = data.scale;
                if(scale != Vector3.zero)
                    danmaku.bulletPrefab.transform.localScale = scale;
                Instantiate<GameObject>(danmaku.bulletPrefab,danmaku.SetBulletSpawnPos(_m, position, data), Quaternion.Euler(0f, 0f, rotation))
                    .GetComponent<Bullet>().SetAwake(_m, data.shotsDelay, damage, danmaku);
                
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
