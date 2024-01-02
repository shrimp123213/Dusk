using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using BehaviorDesigner.Runtime;
using BehaviorDesigner.Runtime.Tasks;
using Unity.VisualScripting;

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
    
    public enum OmenSpawnType
    {
        Start,
        End
    }
    public OmenSpawnType OmenSpawn = OmenSpawnType.Start;

    public bool Flip;

    public bool CheckFacing;
    
    public int Facing;
    
    private bool Fail;

    private Vector3 omenPos;
    
    
    public override void OnStart()
    {
        this.Fail=(this.SelfCharacter.Value.Airbrone || this.SelfCharacter.Value.isDead);
        if (!this.Fail)
        {
            this.SelfCharacter.Value.StartAction(this.Action);
            if (Omen != null)
            {
                Omen.GetComponent<ActionOmen>().SetTarget(OmenSpawnPoint.Value.GameObject());
                if(OmenSpawn == OmenSpawnType.Start)
                {
                    float omenEuler = OmenSpawnEuler;
                    if(OmenSpawnFlip) omenEuler += (this.transform.position.x > this.Target.Value.transform.position.x) ? 180 : 0;
                
                    omenPos = OmenSpawnPointWithTarget ? OmenSpawnPoint.Value.position : new Vector3(transform.position.x, transform.position.y+spawnOffsetY, transform.position.z);
                    GameObject.Instantiate(Omen, omenPos, Quaternion.Euler(0,0,omenEuler));
                    //Omen.transform.localScale = new Vector3(this.SelfCharacter.Value.Facing,1,1);
                }
            }
        }
        if(CheckFacing)
            this.SelfCharacter.Value.Facing = (this.Target.Value.transform.position.x > this.transform.position.x) ? 1 : -1;
        
    }

    public override TaskStatus OnUpdate()
    {
        if (this.Fail)
        {
            return TaskStatus.Failure;
        }
        if (this.SelfCharacter.Value.isActing)
        {
            return TaskStatus.Running;
        }
        return TaskStatus.Success;
    }

    public override void OnEnd()
    {
        if (Flip && !(this.SelfCharacter.Value.isActing))
        {
            this.SelfCharacter.Value.Facing *= -1;
        }
        if(CheckFacing)
            this.SelfCharacter.Value.Facing = (this.Target.Value.transform.position.x > this.transform.position.x) ? 1 : -1;
        if (Omen != null && OmenSpawn == OmenSpawnType.End)
        {
            float omenEuler = OmenSpawnEuler;
            if(OmenSpawnFlip) omenEuler += (this.transform.position.x > this.Target.Value.transform.position.x) ? 180 : 0;
            
            omenPos = OmenSpawnPointWithTarget ? OmenSpawnPoint.Value.position : new Vector3(transform.position.x, transform.position.y+spawnOffsetY, transform.position.z);
            GameObject.Instantiate(Omen, omenPos, Quaternion.Euler(0,0,omenEuler));
            //Omen.transform.localScale = new Vector3(this.SelfCharacter.Value.Facing,1,1);
        }

    }
}
