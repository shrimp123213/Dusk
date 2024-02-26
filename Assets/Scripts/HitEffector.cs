using Unity.VisualScripting;
using UnityEngine;

public class HitEffector : MonoBehaviour
{
    private bool isActionInterrupted;

    public Animator Ani;

    public Character _m;

    public static float GlobalMoveTimeScale = 1f;

    public float AttackStunDura;

    public float HitStun;
    private float defaultHitStun;

    public float HitStunInterval;

    public float TimeSlow;

    public Transform TransSprite;

    public float GlobalSlow;

    public AnimationCurve[] GlobalSlowCurve;
    private int currentCurve = 0;

    private bool isImmuneStunAction;

    private bool ShakeCharacter;

    private int framePassed;

    private void Awake()
    {
        GlobalMoveTimeScale = 1f;
        currentCurve = 0;
        //Time.timeScale = 1f;

        framePassed = 0;
    }

    public void CallAwake(Animator ani)
    {
        Ani = ani;
        TransSprite = base.transform.GetChild(0);
    }

    private void LateUpdate()
    {
        if (GlobalSlow > 0f && framePassed >= 2)
        {
            GlobalSlow -= Time.unscaledDeltaTime;
            Time.timeScale = GlobalSlowCurve[currentCurve].Evaluate(1f - GlobalSlow);
            if (GlobalSlow <= 0f)
            {
                Time.timeScale = 1f;
            }
        }
        else
            framePassed++;
        if (AttackStunDura > 0f)
        {
            AttackStunDura -= Time.deltaTime;
            Ani.speed = 0f;
            if (AttackStunDura <= 0f)
            {
                Ani.speed = 1f;
            }
        }
        if (HitStun > 0f && !_m.isDead)
        {
            HitStunInterval -= Time.unscaledDeltaTime;
            HitStun -= Time.unscaledDeltaTime;
            if (HitStunInterval <= 0f && HitStun > 0f)
            {
                HitStunInterval = 0.025f;
                if (ShakeCharacter)
                    TransSprite.localPosition = new Vector3((TransSprite.localPosition.x <= 0f) ? Random.Range(0.11f, 0.13f) : (0f - Random.Range(0.11f, 0.13f)), TransSprite.localPosition.y, TransSprite.localPosition.z);

                if (!isActionInterrupted && !isImmuneStunAction)
                {
                    Ani.speed = 0f;
                }
            }
            else if (HitStun <= 0f)
            {
                TransSprite.localPosition = new Vector3(0f, TransSprite.localPosition.y, TransSprite.localPosition.z);

                if (isActionInterrupted)
                {
                    AnimatorExtensions.RebindAndRetainParameter(Ani);
                    //Ani.Rebind();
                    Ani.Play("Idle");
                    Ani.Update(0f);
                    isActionInterrupted = false;

                    if ((bool)_m.Player)
                        _m.Player.CanInput = true;
                }

                Ani.speed = 1f;
            }
        }
        if (defaultHitStun > 0)
        {
            HitStunInterval -= Time.unscaledDeltaTime;
            defaultHitStun -= Time.unscaledDeltaTime;
            if (HitStunInterval <= 0f && defaultHitStun > 0f)
            {
                HitStunInterval = 0.025f;
                if (ShakeCharacter)
                    TransSprite.localPosition = new Vector3((TransSprite.localPosition.x <= 0f) ? Random.Range(0.11f, 0.13f) : (0f - Random.Range(0.11f, 0.13f)), TransSprite.localPosition.y, TransSprite.localPosition.z);
            }
            if (defaultHitStun <= 0)
                TransSprite.localPosition = new Vector3(0f, TransSprite.localPosition.y, TransSprite.localPosition.z);
        }
        
        if ((bool)_m.Player && TimeSlow > 0f)
        {
            TimeSlow -= Time.deltaTime;
            if (TimeSlow <= 0f)
            {
                GlobalMoveTimeScale = 1f;
            }
            else
            {
                GlobalMoveTimeScale = 0f;
            }
        }
    }

    public void SetAttackStun()
    {
        AttackStunDura = 0.075f;
    }

    public void SetHitStun(bool _isActionInterrupted, bool _IsImmuneStunAction, float _HitStun = .25f, bool _ShakeCharacter = true)
    {
        if (!isActionInterrupted)//避免被打第一次中斷行動後被打第二次的攻擊沒有附加中斷導致結束暈眩後沒有回到Idle
            isActionInterrupted = _isActionInterrupted;

        isImmuneStunAction = _IsImmuneStunAction;

        ShakeCharacter = _ShakeCharacter;

        HitStun += _HitStun;
        if (_HitStun == 0)
            defaultHitStun = .1f;
    }

    public void SetTimeSlow(float _Time)
    {
        TimeSlow = _Time;
    }

    public void SetGlobalSlow(float _Time, int _currentCurve)
    {
        GlobalSlow = _Time;
        currentCurve = _currentCurve;
        Time.timeScale = 0.01f;
    }

    public void SetGlobalSlowNextFrame(float _Time, int _currentCurve)
    {
        GlobalSlow = _Time;
        currentCurve = _currentCurve;
        //Time.timeScale = 0.01f;
        framePassed = 0;
    }
}
