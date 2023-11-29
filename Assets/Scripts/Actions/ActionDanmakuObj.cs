using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[CreateAssetMenu(fileName = "ActionDanmaku", menuName = "Actions/Danmaku")]
public class ActionDanmakuObj : ActionBaseObj
{
    public GameObject prefabBullet;
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
        for (int i = 0; i < 3; i = num + 1)
        {
            Instantiate<GameObject>(this.prefabBullet, _m.transform.position, Quaternion.identity);//.GetComponent<Bullet>().SetDirection(new Vector2(0f, -1f));
            yield return new WaitForSeconds(0.1f);
            num = i;
        }
    }
}
