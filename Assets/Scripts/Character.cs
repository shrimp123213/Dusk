using System.Collections;
using System.Collections.Generic;
using Unity.Collections;
using UnityEngine;
using DG.Tweening;
using TMPro;
using System;
using System.ComponentModel;
using Spine.Unity;

public class Character : MonoBehaviour, IHitable
{
    [HideInInspector]
    public Animator Ani;

    [HideInInspector]
    public SkeletonAnimation SkeleAni;
    [HideInInspector]
    public Spine.AnimationState SkeleAniState;

    [HideInInspector]
    public Rigidbody2D Rigid;

    public float SpeedFactor = 1f;

    public float Xinput;

    public float Yinput;

    public int Facing = 1;

    public bool KeyJump;

    public bool KeyJumpJust;

    public bool isLocal;

    public bool Charging;

    public bool Airbrone;//被打飛到空中

    public bool isDead;

    public bool Evading;

    public bool CanLongJump;

    public float LowGravityTime;//受傷後減慢?

    //public float ThinkCD;

    public List<InputKey> Inputs;

    public ActionBaseObj NowAction;

    public ActionPeformState ActionState;

    public Dictionary<GameObject, uint> Hitted = new Dictionary<GameObject, uint>();

    public List<ForceMovement> StoredMoves = new List<ForceMovement>();

    private Vector3 LastPos;

    public HitEffector HitEffect;

    [SerializeField]
    private float _Health;

    public CharacterStat HealthMax = new CharacterStat(100f);

    public CharacterStat Speed = new CharacterStat(7.75f);

    public CharacterStat Attack = new CharacterStat(10f);

    //[HideInInspector]
    //public BehaviorTree AITree;

    public TextMeshProUGUI TextInput;

    public Transform TransSkillPopup;

    public Color HurtBoxColor;

    [HideInInspector]
    public PlayerMain Player;

    public int MobId;

    public bool OnLadder;

    public bool isKnockback;

    public float Health
    {
        get
        {
            return _Health;
        }
        set
        {
            _Health = Mathf.Clamp(value, 0f, HealthMax.Final);
        }
    }

    public bool isActing => NowAction != null;

    public bool isMovable
    {
        get
        {
            if (isActing)
            {
                return NowAction.Movable(this);
            }
            return true;
        }
    }

    public bool isGround
    {
        get
        {
            BoxCollider2D component = GetComponent<BoxCollider2D>();
            RaycastHit2D raycastHit2D = Physics2D.BoxCast(component.bounds.center, component.size, 0f, Vector2.down, 0.015f, LayerMask.GetMask("Ground"));
            if ((bool)raycastHit2D)
            {
                //Debug.DrawLine(raycastHit2D.point, component.bounds.center, Color.green, 2f);
                return true;
            }
            //Debug.DrawLine(component.bounds.center, component.bounds.min + Vector3.down * 0.02f, Color.red, 2f);
            return false;
        }
    }

    public bool isOnSlope//////////////////////////判定待改進
    {
        get
        {
            BoxCollider2D component = GetComponent<BoxCollider2D>();
            RaycastHit2D raycastHit2D = Physics2D.Raycast(base.transform.position, -Vector2.up, component.bounds.extents.y + 1f, LayerMask.GetMask("Ground"));
            if (raycastHit2D.collider != null && Mathf.Abs(raycastHit2D.normal.x) > 0.05f)
            {
                return true;
            }
            return false;
        }
    }

    public event Action<Character> OnKillMob;

    private void Awake()
    {
        OnAwake();
    }

    public virtual void OnAwake()
    {
        Rigid = GetComponent<Rigidbody2D>();
        Player = GetComponent<PlayerMain>();
        if ((bool)Player)
            Ani = GetComponentInChildren<Animator>();
        else
        {
            SkeleAni = GetComponent<SkeletonAnimation>();
            SkeleAniState = SkeleAni.AnimationState;
        }

        HitEffect = GetComponent<HitEffector>();
        if ((bool)Player)
            HitEffect.CallAwake(Ani);
        else
            HitEffect.CallAwake(SkeleAniState);
        //AITree = GetComponent<BehaviorTree>();
        //if ((bool)AITree)
        //{
        //    AITree.EnableBehavior();
        //}
        TransSkillPopup = GameObject.Find("SkillPopup").transform;
        Health = HealthMax.Final;
    }

    private void Update()
    {
        OnUpdate();
    }

    public virtual void OnUpdate()
    {
        if (isActing)
        {
            NowAction.ProcessAction(this);
        }
    }

    private void FixedUpdate()
    {
        if (Xinput != 0f && isMovable)
        {
            Facing = ((Xinput > 0f) ? 1 : (-1));
        }
        ProcessInput();
        Move();
        CheckFace();
        if (Airbrone && Rigid.velocity.y <= 0f)
        {
            Airbrone = !isGround;
        }
        if (LowGravityTime > 0f)
        {
            LowGravityTime -= Time.fixedDeltaTime;
        }
    }

    public virtual void TryInput(InputKey _InputKey)
    {
        if (!Inputs.Contains(_InputKey))
        {
            Inputs.Add(_InputKey);
        }
    }

    public virtual void ProcessInput()
    {
        Inputs.Clear();
    }

    public virtual bool TryCastAction(ActionBaseObj _actionBaseObj, bool isShowMessage)
    {
        return true;
    }

    public virtual void StartAction(ActionBaseObj _actionBaseObj)
    {
        string previousId = NowAction == null ? _actionBaseObj.Id == "Gun1" ? "" : _actionBaseObj.Id : NowAction.Id == "Gun1" ? NowAction.PreviousId : NowAction.Id;
        //Debug.Log(previousId);
        NowAction?.EndAction(this);
        NowAction = _actionBaseObj;
        NowAction.PreviousId = previousId;
        Hitted.Clear();
        ActionState = NowAction.StartAction(this);
        if ((bool)Player)
            ActionState.Clip = Ani.GetCurrentAnimatorClipInfo(0)[0].clip;
        else
            ActionState.AniAsset = SkeleAniState.GetCurrent(0).Animation;
        //Debug.Log(ActionState.Clip.name);
        ActionState.TotalFrame = Mathf.RoundToInt(ActionState.Clip.length * ActionState.Clip.frameRate);
        HurtBoxColor = new Color(UnityEngine.Random.Range(0.35f, 1f), UnityEngine.Random.Range(0.35f, 1f), UnityEngine.Random.Range(0.35f, 1f));
        NowAction.Init(this);
        NowAction.Id = _actionBaseObj.Id;
        if (_actionBaseObj.UsePopup)
        {
            SkillPopup.i.ShowMessage(_actionBaseObj.DisplayName);
        }
    }

    public virtual void AttackLand()
    {
        HitEffect.SetAttackStun();
    }

    public virtual bool TryLink(string _Id, bool _forceSuccess = false)
    {
        return false;
    }

    public void RegisterHit(GameObject _gameObject)
    {
        if (Hitted.ContainsKey(_gameObject))
        {
            Hitted[_gameObject]++;
        }
        else
        {
            Hitted.Add(_gameObject, 1u);
        }
    }

    public bool isMaxHit(GameObject _gameObject, int _count)
    {
        if (!Hitted.ContainsKey(_gameObject))
        {
            return false;
        }
        if (Hitted[_gameObject] >= _count)
        {
            return true;
        }
        return false;
    }

    public void StopMove()
    {
        Xinput = 0f;
        if ((bool)Player)
        {
            Ani.SetBool("Moving", value: false);
        }
    }

    private void LadderMove()
    {
        Vector2 zero = Vector2.zero;
        Rigid.constraints = RigidbodyConstraints2D.FreezeRotation;
        bool value = false;
        if (Yinput != 0f)
        {
            value = true;
            zero.y = Yinput * (Speed.Final * 0.75f) * SpeedFactor;
        }
        if (Xinput != 0f)
        {
            value = true;
            zero.x = Xinput * Speed.Final * SpeedFactor;
        }
        if (StoredMoves.Count > 0)
        {
            StoredMoves.Clear();
        }
        if ((bool)Player)
        {
            Ani.SetBool("Moving", value);
        }
        Rigid.gravityScale = 0f;
        Rigid.velocity = zero;
    }

    public void Move()
    {
        //if ((bool)Player && Player.Swinger.isSwinging)
        //{
        //    return;
        //}
        if (OnLadder)
        {
            LadderMove();
            return;
        }
        int num = (isMovable ? 1 : 0);
        float num2 = (isLocal ? 1f : HitEffector.GlobalMoveTimeScale);
        Vector2 velocity = Rigid.velocity;
        RigidbodyConstraints2D rigidbodyConstraints2D = RigidbodyConstraints2D.None;
        Rigid.constraints = RigidbodyConstraints2D.FreezeRotation;
        bool value = false;
        if (isKnockback)
        {
            if (velocity.y <= 0f && isGround)
            {
                isKnockback = false;
                Rigid.drag = 0f;
            }
            else
            {
                Rigid.drag = Mathf.Lerp(Rigid.drag, 7.5f, Time.fixedDeltaTime * 7.5f);
            }
        }
        else if (Xinput != 0f && !Airbrone)
        {
            value = true;
            velocity.x = Speed.Final * (float)num * num2 * TryIsNotBlockedByCharacter() * SpeedFactor * ((Mathf.Abs(Xinput) > 0.25f) ? 1f : 0.5f) * (float)((Xinput > 0f) ? 1 : (-1));
        }
        else
        {
            if (isOnSlope)
            {
                rigidbodyConstraints2D = RigidbodyConstraints2D.FreezePositionX;
            }
            velocity.x = velocity.x * 35f * Time.fixedDeltaTime * num2 * TryIsNotBlockedByCharacter();
        }
        if (LastPos == base.transform.position)
        {
            value = false;
        }
        if ((bool)Player)
        {
            Ani.SetBool("Moving", value);
            Ani.SetBool("Jumping", !isGround);
        }
        if (KeyJumpJust)
        {
            KeyJumpJust = false;
            if (isGround && !isActing)
            {
                CanLongJump = true;
                LowGravityTime = 0f;
                velocity.y = 18.5f;
            }
        }
        if (CanLongJump && !KeyJump)
        {
            CanLongJump = false;
        }
        Vector2 vector = ((LowGravityTime > 0f) ? new Vector2(-0.25f, 0.5f) : Vector2.one);
        if (Rigid.velocity.y < 0f)
        {
            velocity.y = Physics2D.gravity.y * vector.x * 5.25f * Time.fixedDeltaTime * (float)num + velocity.y * (float)num * num2;
            Ani.SetFloat("VelocityY", velocity.y);
        }
        else if (Rigid.velocity.y > 0f && KeyJump && CanLongJump)
        {
            velocity.y = Physics2D.gravity.y * vector.y * 2.25f * Time.fixedDeltaTime * (float)num + velocity.y * (float)num * num2;
            Ani.SetFloat("VelocityY", velocity.y);
        }
        else if (Rigid.velocity.y > 0f)
        {
            velocity.y = Physics2D.gravity.y * vector.y * 5.5f * Time.fixedDeltaTime * (float)num + velocity.y * (float)num * num2;
            Ani.SetFloat("VelocityY", velocity.y);
        }
        if (num == 0 || LowGravityTime > 0f)
        {
            Rigid.gravityScale = 0f;
        }
        else
        {
            Rigid.gravityScale = 1f * num2;
        }
        if (StoredMoves.Count > 0)
        {
            List<ForceMovement> list = null;
            Vector3 zero = Vector3.zero;
            for (int i = 0; i < StoredMoves.Count; i++)
            {
                ForceMovement forceMovement = StoredMoves[i];
                Vector3 vector2 = Vector3Utli.CacuFacing(Vector3Utli.CacuVector2Curve(forceMovement.Base.Power_ZTime, forceMovement.Base.XCurve, forceMovement.Base.YCurve, forceMovement.TimeUsed / forceMovement.Base.Power_ZTime.z), Facing);
                zero += vector2;
                if (forceMovement.TimeUsed >= forceMovement.Base.Power_ZTime.z)
                {
                    if (list == null)
                    {
                        list = new List<ForceMovement>();
                    }
                    list.Add(forceMovement);
                }
                forceMovement.TimeUsed += Time.fixedDeltaTime * num2;
            }
            if (list != null)
            {
                foreach (ForceMovement item in list)
                {
                    StoredMoves.Remove(item);
                }
            }
            Rigid.MovePosition(base.transform.position + zero * Time.fixedDeltaTime * num2);
            if (zero.x != 0f)
            {
                rigidbodyConstraints2D = RigidbodyConstraints2D.None;
            }
        }
        Rigid.constraints = rigidbodyConstraints2D | RigidbodyConstraints2D.FreezeRotation;
        Rigid.velocity = velocity;
        LastPos = base.transform.position;
    }

    public void CheckFace()
    {
        base.transform.GetChild(0).localScale = new Vector3(Mathf.Abs(base.transform.GetChild(0).localScale.x) * (float)Facing, base.transform.GetChild(0).localScale.y, 1f);
    }

    public bool TakeDamage(Damage _damage, Character _attacker = null)
    {
        if (isDead)
        {
            return false;
        }
        if (_damage.Type != DamageType.Heal)
        {
            if (Evading)
            {
                OnEvading();
                return false;
            }
            SpriteRenderer component = base.gameObject.transform.GetChild(0).GetComponent<SpriteRenderer>();
            //DOTween.Sequence().Append(component.DOFade(1.75f, 0.1f));//.Append(component.DOFade(1f, 0.15f));
            //DOTween.Sequence().Append(component.DOColor(new Color(1f, 0.675f, 0.675f), 0.1f)).Append(component.DOColor(Color.white, 0.25f));
            //Debug.Log("Hit : " + base.gameObject.name);
            LowGravityTime = 0.665f;
            HitEffect.SetHitStun();
            //if ((bool)AITree)
            //{
            //    AITree.SendEvent("Attacked", (object)_attacker.transform);
            //    BehaviorManager.instance.Tick(AITree);
            //    AITree.DisableBehavior(pause: true);
            //    CancelInvoke("ResumeAI");
            //    Invoke("ResumeAI", 0.75f);
            //}
        }
        Health = Mathf.Clamp(Health - _damage.Amount, 0f, HealthMax.Final);
        if (Health <= 0f)
        {
            if ((bool)_attacker)
            {
                _attacker.OnKillMob?.Invoke(this);
            }
            Dead();
        }
        return true;
    }

    public virtual void OnEvading()
    {
        

        
    }

    public void SetAnimationIdle()
    {
        Ani.Play((Xinput != 0f) ? "Run" : "Idle");
        Ani.Update(0f);
    }

    public virtual void Dead()
    {
        isDead = true;
        SpriteRenderer component = base.gameObject.transform.GetChild(0).GetComponent<SpriteRenderer>();
        DOTween.Sequence().Append(component.DOFade(0.35f, 0.35f)).Append(component.DOFade(0f, 0.15f));
        //AITree.enabled = false;
        base.gameObject.layer = 9;
        for (int i = 0; i < UnityEngine.Random.Range(2, 4); i++)
        {
            //UnityEngine.Object.Instantiate(GeneralPrefabSO.i.P_HealthShard, base.transform.position + new Vector3(0f, 1.25f), Quaternion.identity);
        }
        base.gameObject.SetActive(value: false);
    }

    public void TakeForce(Vector2 _Force, Vector2 _AddiForce)
    {
        if (isActing)
        {
            NowAction.EndAction(this);
        }
        if (!isGround)
        {
            Rigid.velocity = Vector2.zero;
            Rigid.AddForce(new Vector2(_Force.x + _AddiForce.x, ((_Force.y == 0f) ? 3f : _Force.y) + _AddiForce.y) * Rigid.mass, ForceMode2D.Impulse);
            //AerutaDebug.i.CallEffect(0);
        }
        else
        {
            Rigid.velocity = Vector2.zero;
            Rigid.AddForce(_Force * Rigid.mass, ForceMode2D.Impulse);
            if (_Force.y > 0f)
            {
                Airbrone = true;
            }
            //Debug.Log(string.Concat(Rigid.velocity, isActing.ToString()));
        }
        isKnockback = true;
        CanLongJump = false;
        Rigid.drag = 0f;
        //if (!AITree)
        //{
            Ani.Play("Attacked");
            Ani.Update(0f);
            HitEffect.SetTimeSlow(0.15f);
        //}
    }

    public void ResumeAI()
    {
        //AITree.EnableBehavior();
    }

    public int TryIsNotBlockedByCharacter()
    {
        BoxCollider2D component = GetComponent<BoxCollider2D>();
        RaycastHit2D[] raycastHit2D = Physics2D.RaycastAll(component.bounds.center, Vector2.right * Facing, component.bounds.extents.x + .1f, LayerMask.GetMask("Character"));

        if (raycastHit2D.Length <= 1)//只有射到自己
            return 1;

        foreach (RaycastHit2D hit in raycastHit2D)
        {
            if (hit.collider.name != component.name)
            {
                if (hit.point.x >= hit.collider.bounds.max.x || hit.point.x <= hit.collider.bounds.min.x)
                {
                    Debug.DrawLine(hit.point, component.bounds.center, Color.red, 2f);
                    return 0;
                }
            }
        }
        
        Debug.DrawLine(component.bounds.center, component.bounds.center + (component.bounds.extents.x + .1f) * Vector3.right * Facing, Color.green, 2f);
        return 1;
    }
}

public enum CharacterStates
{
    Idle,
    Walking,
    Jumping,

}

public interface IHitable
{
    bool TakeDamage(Damage _damage, Character _attacker = null);
}