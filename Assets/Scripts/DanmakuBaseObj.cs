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
    public float timeBetweenShots = 0f;
    public int shotsPerInterval = 1;
    
    [Space]
    [Header("子彈生成")]
    public List<BulletSpawnData> bulletSpawnData;
    
    private Vector3 bulletSpawnPos;
    
    public Vector3 SetBulletSpawnPos(Character _m, Vector3 mPosition, BulletSpawnData data)
    {
        switch (data.spawnType)
        {
            case SpawnType.Base:
                bulletSpawnPos = Vector3Utility.CacuFacing(data.position,_m.Facing) + mPosition;
                break;
            case SpawnType.Global:
                bulletSpawnPos = new Vector3(data.position.x, data.position.y);
                break;
            case SpawnType.Screen:
                bulletSpawnPos = Camera.main.WorldToScreenPoint(data.position);
                break;
        }
        return bulletSpawnPos;
    }
}



[Serializable]
public class BulletSpawnData
{
    public int shootKey;
    public DanmakuType danmakuType;
    public SpawnType spawnType;
    public Vector3 position;
    
    [Space]
    public float shotsDelay = 0;
    
    [Space]
    public float rotation;
    
    public BulletSpawnData(BulletSpawnData _bulletSpawnData)
    {
        shotsDelay = _bulletSpawnData.shotsDelay;
        shootKey = _bulletSpawnData.shootKey;
        danmakuType = _bulletSpawnData.danmakuType;
        spawnType = _bulletSpawnData.spawnType;
        position = _bulletSpawnData.position;
        rotation = _bulletSpawnData.rotation;
    }

    [Header("紅眼提示")]
    public bool SpawnOmen;
    public int SpawnKeyFrame;
}
