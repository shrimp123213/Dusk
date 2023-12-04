using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public enum DanmakuType { Straight, Homing }
public enum FireMode { Single, Scatter }
public enum SpawnType { Base, Global, Screen }
[CreateAssetMenu(fileName = "NewDanmakuData", menuName = "Danmaku/DanmakuData")]
public class DanmakuBaseObj : ScriptableObject
{
    public DanmakuType danmakuType;
    public FireMode fireMode;
    
    [Header("子彈設定")]
    public GameObject bulletPrefab;
    public float bulletSpeed;
    public AnimationCurve speedCurve = AnimationCurve.Linear(0, 1, 1, 1);
    
    [Header("散射設定")]
    public int numberOfBullets;
    public float scatterAngle;
    
    [Header("追尾設定")]
    public float rotationSpeed;
    
    [Header("射擊頻率")]
    public float timeBetweenShots = 0.5f;
    public int shotsPerInterval = 1;
    
    [Space]
    [Header("子彈生成")]
    public List<BulletSpawnData> bulletSpawnData;
    
    public virtual Vector3 SetBulletSpawnPos(Character _m, BulletSpawnData data)
    {
        switch (data.spawnType)
        {
            case SpawnType.Base:
                data.position += _m.transform.position;
                break;
            case SpawnType.Global:
                data.position = new Vector3(data.position.x, data.position.y);
                break;
            case SpawnType.Screen:
                data.position = Camera.main.WorldToScreenPoint(data.position);
                break;
        }
        return data.position;
    }
}



[Serializable]
public class BulletSpawnData
{
    public SpawnType spawnType;
    public Vector3 position;
    
    [Space]
    public Quaternion rotation;
    
    public BulletSpawnData(SpawnType _spawnType, Vector3 _position, Quaternion _rotation)
    {
        spawnType = _spawnType;
        position = _position;
        rotation = _rotation;
    }
}
