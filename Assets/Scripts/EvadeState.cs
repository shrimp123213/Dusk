using Spine.Unity;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class EvadeState : MonoBehaviour
{
    public bool CanEvade;

    public bool IsRewarded;

    public float EvadeCooldown;

    public float EvadeCooldownMax;

    //public ParticleSystem EvadeCanUseEffect;

    public ParticleSystem EvadeDistanceEffect;

    //public GameObject EvadeFinishCooldownEffect;

    //public GameObject EvadeSuccessEffect;

    public SkeletonMecanim Renderer;

    private void Start()
    {
        EvadeDistanceEffect.Stop();
    }

    private void Update()
    {
        if (!CanEvade)
        {
            EvadeCooldown -= Time.deltaTime;
            if (EvadeCooldown < 0f)
            {
                EvadeReady(true);
            }
        }
    }

    public void EvadeReady(bool spawnEffect)
    {
        EvadeCooldown = EvadeCooldownMax;
        CanEvade = true;

        //if(spawnEffect) Instantiate(EvadeFinishCooldownEffect, transform.position, Quaternion.identity, transform);

        //EvadeCanUseEffect.Stop();
        //var main = EvadeCanUseEffect.main;
        //main.loop = true;
        //EvadeCanUseEffect.Play();
    }

    public void UseEvade(Character _m)
    {
        CanEvade = false;
        IsRewarded = false;
        
        //EvadeCanUseEffect.Stop();
        //var main = EvadeCanUseEffect.main;
        //main.loop = false;
        
        EvadeDistanceEffect.Play();
        EvadeDistanceEffect.transform.rotation = _m.Facing == 1 ? Quaternion.identity : Quaternion.Euler(Vector3.forward * 180);

        _m.Evading = true;
    }

    public void EvadingTransparency()
    {
        Color currentColor = Renderer.skeleton.GetColor();
        Renderer.skeleton.SetColor(new Color(currentColor.r, currentColor.g, currentColor.b, .5f));
    }

    public void ReturnTransparency()
    {
        Color currentColor = Renderer.skeleton.GetColor();
        Renderer.skeleton.SetColor(new Color(currentColor.r, currentColor.g, currentColor.b, 1f));
    }
}
