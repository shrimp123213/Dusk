using UnityEngine;

public class HitEffector : MonoBehaviour
{
    private bool isActionInterrupted;

    private Animator Ani;

    public bool Main;

    public static float GlobalMoveTimeScale = 1f;

    public float AttackStunDura;

    public float HitStun;

    public float HitStunInterval;

    public float TimeSlow;

    public Transform TransSprite;

    public float GlobalSlow;

    public AnimationCurve[] GlobalSlowCurve;
    private int currentCurve = 0;

    private bool isImmuneStunAction;

    private bool ShakeCharacter;

    private void Awake()
    {
        GlobalMoveTimeScale = 1f;
        currentCurve = 0;
        //Time.timeScale = 1f;
    }

    public void CallAwake(Animator ani)
    {
        Ani = ani;
        TransSprite = base.transform.GetChild(0);
    }

    private void LateUpdate()
    {
        if (GlobalSlow > 0f)
        {
            GlobalSlow -= Time.unscaledDeltaTime;
            Time.timeScale = GlobalSlowCurve[currentCurve].Evaluate(1f - GlobalSlow);
            if (GlobalSlow <= 0f)
            {
                Time.timeScale = 1f;
            }
        }
        if (AttackStunDura > 0f)
        {
            AttackStunDura -= Time.deltaTime;
            Ani.speed = 0f;
            if (AttackStunDura <= 0f)
            {
                Ani.speed = 1f;
            }
        }
        if (HitStun > 0f)
        {
            HitStunInterval -= Time.deltaTime;
            HitStun -= Time.deltaTime;
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
                }

                Ani.speed = 1f;
            }
        }
        if (Main && TimeSlow > 0f)
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
}
