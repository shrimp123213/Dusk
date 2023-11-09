using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class EvadeState : MonoBehaviour
{
    public bool CanEvade;

    public bool IsDamageAvoided;

    public float EvadeCooldown;

    public float EvadeCooldownMax;

    public GameObject EvadeUseEffect;

    public ParticleSystem EvadeCanUseEffect;

    public ParticleSystem EvadeDistanceEffect;

    public GameObject EvadeFinishCooldownEffect;

    public GameObject EvadeSuccessEffect;

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
                EvadeCooldown = EvadeCooldownMax;
                CanEvade = true;

                Instantiate(EvadeFinishCooldownEffect, transform.position, Quaternion.identity, transform);

                EvadeCanUseEffect.Stop();
                var main = EvadeCanUseEffect.main;
                main.loop = true;
                EvadeCanUseEffect.Play();

            }
        }
    }

    public void UseEvade(Character _m)
    {
        CanEvade = false;
        IsDamageAvoided = false;

        //Instantiate(EvadeUseEffect, transform.position, _m.Facing == 1 ? Quaternion.identity : Quaternion.Euler(Vector3.forward * 180), transform);

        EvadeCanUseEffect.Stop();
        var main = EvadeCanUseEffect.main;
        main.loop = false;

        EvadeDistanceEffect.Play();
        EvadeDistanceEffect.transform.rotation = _m.Facing == 1 ? Quaternion.identity : Quaternion.Euler(Vector3.forward * 180);

        _m.Evading = true;
    }
}
