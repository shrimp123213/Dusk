using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[CreateAssetMenu(fileName = "ActionDanmaku", menuName = "Actions/Danmaku")]
public class ActionDanmakuObj : ActionBaseObj
{
    public DanmakuBaseObj danmakuBaseObj;
    
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
        int num;
        for (int i = 0; i < danmakuBaseObj.shotsPerInterval; i = num + 1)
        {
            foreach (var data in danmakuBaseObj.bulletSpawnData)
            {
                Instantiate<GameObject>(danmakuBaseObj.bulletPrefab,danmakuBaseObj.SetBulletSpawnPos(_m, data), data.rotation);//.GetComponent<Bullet>().SetDirection(new Vector2(0f, -1f));
                
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
            
            yield return new WaitForSeconds(danmakuBaseObj.timeBetweenShots);
            num = i;
        }
    }
    
    
}
