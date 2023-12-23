using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[CreateAssetMenu(fileName = "ActionDanmaku", menuName = "Actions/Danmaku")]
public class ActionDanmakuObj : ActionBaseObj
{
    [Header("彈幕設定")]
    public DanmakuBaseObj danmaku;
    
    public int shootKey;
    
    public override void ProcessAction(Character _m)
    {
        base.ProcessAction(_m);
        ActionPeformState actionState = _m.ActionState;
        if (actionState.CanDoThingsThisUpdateVirtual() && actionState.IsAtFrame(this.shootKey))
        {
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


    private IEnumerator SpawnBullet(Character _m)
    {
        for (int i = 0; i < danmaku.shotsPerInterval; i++)
        {
            foreach (var data in danmaku.bulletSpawnData)
            {
                var rotation = _m.Facing > 0 ? data.rotation : -data.rotation;
                Instantiate<GameObject>(danmaku.bulletPrefab,danmaku.SetBulletSpawnPos(_m, data), Quaternion.Euler(0f, 0f, rotation))
                    .GetComponent<Bullet>().SetAwake(_m, new Damage(_m.Attack.Final*DamageRatio,DamageType.Normal), danmaku);
                
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
