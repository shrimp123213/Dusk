using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using BehaviorDesigner.Runtime;
using BehaviorDesigner.Runtime.Tasks;
using Unity.VisualScripting;
using Cinemachine;

public class EnemyStartAction : EnemyActionBase
{
    public SharedTransform Target;
    
    public ActionBaseObj Action;
    
    public GameObject Omen;
    public float OmenSpawnEuler = 0;
    public bool OmenSpawnFlip = false;
    public float spawnOffsetY = 0;
    
    public SharedTransform OmenSpawnPoint;
    public bool OmenSpawnPointWithTarget = true;

    public bool Flip;

    public bool CheckFacing;
    
    public int Facing;
    
    public bool Fail;

    public bool spawnBlur;
    public int blurFrame;
    private bool blurSpawned;
    
    public bool spawnDust;
    public int dustFrame;
    private bool dustSpawned;
    public GameObject DustEffect;
    
    public bool spawnImpulse;
    public int impulseFrame;
    private bool impulseSpawned;

    private Vector3 omenPos;

    private bool[] omenSpawned;

    public override void OnStart()
    {
        this.Fail=(this.SelfCharacter.Value.Airbrone || this.SelfCharacter.Value.isDead);
        if (!this.Fail)
        {
            this.SelfCharacter.Value.StartAction(this.Action);
            
        }
        if(CheckFacing)
            this.SelfCharacter.Value.Facing = (this.Target.Value.transform.position.x > this.transform.position.x) ? 1 : -1;

        int count = SelfCharacter.Value.NowAction.AttackSpots.Count;
        if (SelfCharacter.Value.NowAction.GetType() == typeof(ActionDanmakuObj))
            count += ((ActionDanmakuObj)SelfCharacter.Value.NowAction).danmaku.bulletSpawnData.Count;
        omenSpawned = new bool[count];
        blurSpawned = false;
        dustSpawned = false;
        impulseSpawned = false;
    }

    public override TaskStatus OnUpdate()
    {
        if (this.Fail)
        {
            return TaskStatus.Failure;
        }
        if (this.SelfCharacter.Value.isActing)
        {
            TrySpawnOmen();
            
            if (spawnBlur)
                TrySpawnBlur();
            
            if (spawnDust)
                TrySpawnDust();
            if(spawnImpulse)
                TrySpawnImpulse();
            
            return TaskStatus.Running;
        }
        return TaskStatus.Success;
    }

    public virtual void TrySpawnOmen()
    {
        ActionPeformState actionState = SelfCharacter.Value.ActionState;

        List<AttackTiming> _AttackSpots = SelfCharacter.Value.NowAction.AttackSpots;
        for (int i = 0; i < _AttackSpots.Count; i++) 
        {
            if (Omen != null && _AttackSpots[i].SpawnOmen && !omenSpawned[i] && actionState.IsAfterFrame(_AttackSpots[i].SpawnKeyFrame))
            {
                Omen.GetComponent<ActionOmen>().SetTarget(OmenSpawnPoint.Value.GameObject());

                omenPos = OmenSpawnPointWithTarget ? OmenSpawnPoint.Value.position : new Vector3(transform.position.x, transform.position.y + spawnOffsetY, transform.position.z);
                Transform omenTransform = OmenSpawnPointWithTarget ? OmenSpawnPoint.Value.transform : null;

                Quaternion omenRot = Quaternion.Euler(new Vector3(0, 0, OmenSpawnEuler));
                
                
                
                var omenObj = GameObject.Instantiate(Omen, omenPos, omenRot, omenTransform);
                if(OmenSpawnFlip)
                    omenObj.transform.localScale = new Vector3(this.SelfCharacter.Value.Facing, 1, 1);
                //Omen.transform.localScale = new Vector3(this.SelfCharacter.Value.Facing,1,1);

                omenSpawned[i] = true;
            }
        }

        if (SelfCharacter.Value.NowAction.GetType() == typeof(ActionDanmakuObj))
        {
            List<BulletSpawnData> _bulletSpawnData = ((ActionDanmakuObj)SelfCharacter.Value.NowAction).danmaku.bulletSpawnData;
            for (int i = 0; i < _bulletSpawnData.Count; i++)
            {
                if (Omen != null && _bulletSpawnData[i].SpawnOmen && !omenSpawned[i] && actionState.IsAfterFrame(_bulletSpawnData[i].SpawnKeyFrame))
                {
                    Omen.GetComponent<ActionOmen>().SetTarget(OmenSpawnPoint.Value.GameObject());

                    omenPos = OmenSpawnPointWithTarget ? OmenSpawnPoint.Value.position : new Vector3(transform.position.x, transform.position.y + spawnOffsetY, transform.position.z);
                    Transform omenTransform = OmenSpawnPointWithTarget ? OmenSpawnPoint.Value.transform : null;

                    Quaternion omenRot = Quaternion.Euler(new Vector3(0, 0, OmenSpawnEuler));
                
                    var omenObj = GameObject.Instantiate(Omen, omenPos, omenRot, omenTransform);
                    if(OmenSpawnFlip)
                        omenObj.transform.localScale = new Vector3(this.SelfCharacter.Value.Facing, 1, 1);
                    //Omen.transform.localScale = new Vector3(this.SelfCharacter.Value.Facing,1,1);

                    omenSpawned[i] = true;
                }
            }
        }
    }
    
    public virtual void TrySpawnBlur()
    {
        ActionPeformState actionState = SelfCharacter.Value.ActionState;
        Transform eye = this.SelfCharacter.Value.transform.Find("Eye");
        if (actionState.IsAfterFrame(blurFrame) && !blurSpawned)
        {
            AerutaDebug.i.forBoss0 = true;
            AerutaDebug.i.SpawnPostBlurZoomOut(eye.position);
            blurSpawned = true;
        }
    }

    public virtual void TrySpawnDust()
    {
        ActionPeformState actionState = SelfCharacter.Value.ActionState;
        Transform foot = this.SelfCharacter.Value.transform;
        if (actionState.IsAfterFrame(dustFrame) && !dustSpawned)
        {
            GameObject.Instantiate(DustEffect, foot.position, Quaternion.identity, foot);
            dustSpawned = true;
        }
        
    }
    
    public virtual void TrySpawnImpulse()
    {
        CinemachineImpulseSource impulse = this.SelfCharacter.Value.GameObject().GetComponent<CinemachineImpulseSource>();
        ActionPeformState actionState = SelfCharacter.Value.ActionState;
        if (impulse)
        {
            if (actionState.IsAfterFrame(impulseFrame) && !impulseSpawned)
            {
                impulse.GenerateImpulse();
                impulseSpawned = true;
            }
        }
    }

    public override void OnEnd()
    {
        if (Flip && !(this.SelfCharacter.Value.isActing))
        {
            this.SelfCharacter.Value.Facing *= -1;
        }
        if(CheckFacing)
            this.SelfCharacter.Value.Facing = (this.Target.Value.transform.position.x > this.transform.position.x) ? 1 : -1;
    }
}
