using System.Collections;
using System.Collections.Generic;
using Unity.Collections;
using UnityEngine;
using DG.Tweening;
using TMPro;
using System;
using BehaviorDesigner.Runtime;
using System.Reflection;
using Spine.Unity;
using System.Runtime.ConstrainedExecution;
using static UnityEngine.Rendering.DebugUI;

public class Character : MonoBehaviour, IHitable
{
    public Animator Ani;

    [HideInInspector]
    public Rigidbody2D Rigid;

    [HideInInspector]
    public Collider2D Collider; 
    [HideInInspector]
    public Collider2D HurtBox;
    [HideInInspector]
    public Collider2D CollisionBlockMove;

    public Vector2 PietaPos;
    public Vector2 MarkPos;
    public float SliceMultiply = 1f;

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

    public bool Blocking;

    public bool CanLongJump;

    public bool CanDoubleJump;

    private bool DoubleJumped;

    public bool ImmuneInterruptAction;

    public bool ImmuneStunAction;

    public float LowGravityTime;//受傷後減慢?

    //public float ThinkCD;

    public List<InputKey> Inputs;

    public ActionBaseObj NowAction;

    public ActionPeformState ActionState;

    public Dictionary<HittedGameObjectKey, uint> Hitted = new Dictionary<HittedGameObjectKey, uint>(new HittedGameObjectKey.EqualityComparer());

    public List<ForceMovement> StoredMoves = new List<ForceMovement>();

    private Vector3 LastPos;

    public HitEffector HitEffect;

    [SerializeField]
    private float _Health;

    public CharacterStat HealthMax = new CharacterStat(100f);

    public CharacterStat Speed = new CharacterStat(5.5f);

    public CharacterStat Attack = new CharacterStat(10f);

    [HideInInspector]
    public BehaviorTree AITree;
    public Vector2 TeleportKeyReference;

    public TextMeshProUGUI TextInput;

    public Transform TransSkillPopup;

    public Color HurtBoxColor;

    [HideInInspector]
    public PlayerMain Player;

    public int MobId;

    public bool OnLadder;

    public bool isKnockback;

    public List<TimedLink> TimedLinks;

    private bool setAnimationIdle;

    private AnimatorControllerParameter[] AniParameters;

    public SkeletonMecanim Renderer;

    public ActionBaseObj DeadAction;

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

    public bool isMovableX
    {
        get
        {
            if (isActing)
            {
                return NowAction.MovableX(this);
            }
            return true;
        }
    }
    public bool isMovableY
    {
        get
        {
            if (isActing)
            {
                return NowAction.MovableY(this);
            }
            return true;
        }
    }
    public bool canChangeFacingWhenActing
    {
        get
        {
            if (isActing)
            {
                return NowAction.CanChangeFacing(this);
            }
            return true;
        }
    }
    public bool canJumpWhenActing
    {
        get
        {
            if (isActing)
            {
                return NowAction.CanJump(this);
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
        Collider = GetComponent<Collider2D>();
        HurtBox = TransformUtility.FindTransform(transform, "HurtBox").GetComponent<Collider2D>();
        CollisionBlockMove = TransformUtility.FindTransform(transform, "CollisionBlockMove").GetComponent<Collider2D>();
        Rigid = GetComponent<Rigidbody2D>();
        Player = GetComponent<PlayerMain>();
        Ani = GetComponentInChildren<Animator>();
        HitEffect = GetComponent<HitEffector>();
        HitEffect.CallAwake(Ani);

        AITree = GetComponent<BehaviorTree>();
        if ((bool)AITree)
            TeleportKeyReference = (AITree.GetVariable("TeleportTargetPos") as SharedVector2).Value;
        //AITree = GetComponent<BehaviorTree>();
        //if ((bool)AITree)
        //{
        //    AITree.EnableBehavior();
        //}

        TransSkillPopup = GameObject.Find("SkillPopup").transform;
        Health = HealthMax.Final;
        //Debug.Log(Ani);

        Renderer = base.gameObject.transform.GetChild(0).GetComponent<SkeletonMecanim>();
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
        if (isDead && Renderer.skeleton.GetColor().a <= 0) 
            base.gameObject.SetActive(value: false);
    }

    private void FixedUpdate()
    {
        if (Xinput != 0f && isMovableX && canChangeFacingWhenActing && StoredMoves.Count <= 0)
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
        if(DoubleJumped)
        {
            DoubleJumped = !isGround;
        }


        if (setAnimationIdle && NowAction == null)
        {
            if (Ani.GetCurrentAnimatorClipInfo(0)[0].clip.name != "Attacked")
            {
                AnimatorExtensions.RebindAndRetainParameter(Ani);
                //Ani.Rebind();
                Ani.Play((Xinput != 0f) ? "Run" : "Idle");
                Ani.Update(0f);
            }

            setAnimationIdle = false;
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
        string previousId = NowAction == null ? _actionBaseObj.Id : NowAction.Id;
        //Debug.Log(previousId);
        NowAction?.EndAction(this);
        NowAction = _actionBaseObj;
        Hitted.Clear();
        if (StoredMoves.Count > 0)
        {
            StoredMoves.Clear();
        }
        ActionState = NowAction.StartAction(this);
        ActionState.Clip = Ani.GetCurrentAnimatorClipInfo(0)[0].clip;
        ActionState.TotalFrame = Mathf.RoundToInt(ActionState.Clip.length * ActionState.Clip.frameRate);
        //Debug.Log(ActionState.TotalFrame);
        HurtBoxColor = new Color(UnityEngine.Random.Range(0.35f, 1f), UnityEngine.Random.Range(0.35f, 1f), UnityEngine.Random.Range(0.35f, 1f));
        NowAction.Init(this);
        NowAction.Id = _actionBaseObj.Id;
        if (_actionBaseObj.UsePopup)
        {
            SkillPopup.i.ShowMessage(_actionBaseObj.DisplayName);
        }
    }

    public virtual void TriggerMark()
    {
    }

    public virtual void AttackLand()
    {
        //HitEffect.SetAttackStun();
    }

    public virtual bool TryLink(ActionLink link, bool _forceSuccess = false)
    {
        return false;
    }

    public void RegisterHit(HittedGameObjectKey key)
    {
        if (Hitted.ContainsKey(key))
        {
            Hitted[key]++;
        }
        else
        {
            Hitted.Add(key, 1u);
        }
    }

    public bool isMaxHit(HittedGameObjectKey key, int _count)
    {
        if (!Hitted.ContainsKey(key))
        {
            return false;
        }
        if (Hitted[key] >= _count)
        {
            return true;
        }
        return false;
    }

    public void StopMove()
    {
        Xinput = 0f;
        Ani.SetBool("Moving", value: false);
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
        Ani.SetBool("Moving", value);
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
        if (HitEffect.HitStun > 0)
        {
            StopMove();
        }
        int numX = (isMovableX ? 1 : 0);
        int numY = (isMovableY ? 1 : 0);
        float num2 = (isLocal ? 1f : HitEffector.GlobalMoveTimeScale);
        Vector2 velocity = Rigid.velocity;
        RigidbodyConstraints2D rigidbodyConstraints2D = RigidbodyConstraints2D.None;
        Rigid.constraints = RigidbodyConstraints2D.FreezeRotation;
        bool value = false;
        if (isKnockback)
        {
            if (/*velocity.y <= 0f && isGround LowGravityTime <= 0f || isGround*/true)
            {
                isKnockback = false;
                Rigid.drag = 0f;

                LowGravityTime = 0f;
            }
            else
            {
                Rigid.drag = Mathf.Lerp(Rigid.drag, 7.5f, Time.fixedDeltaTime * 7.5f);
            }
        }
        else if (Xinput != 0f && !Airbrone && isMovableX)
        {
            value = true;
            velocity.x = Speed.Final /* * (float)numX */ * num2 * TryIsNotBlockedByCharacter() * SpeedFactor * ((Mathf.Abs(Xinput) > 0.25f) ? 1f : 0.5f) * (float)((Xinput > 0f) ? 1 : (-1));
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
        Ani.SetBool("Moving", value);
        Ani.SetBool("Jumping", !isGround);
        if (KeyJumpJust)
        {
            KeyJumpJust = false;
            if (isGround && canJumpWhenActing)
            {
                CanLongJump = true;
                LowGravityTime = 0f;
                velocity.y = 20f;
            }
            else if (!isGround && canJumpWhenActing && CanDoubleJump && !DoubleJumped)
            {
                CanLongJump = true;
                LowGravityTime = 0f;
                velocity.y = 20f;

                if (!isActing)
                {
                    AnimatorExtensions.RebindAndRetainParameter(Ani);
                    //Ani.Rebind();
                    Ani.Play("Jump up");
                    Ani.Update(0f);
                }

                DoubleJumped = true;
                if ((bool)Player)
                    Instantiate(Player.DoubleJumpEffect, transform.position, Quaternion.identity, null);
            }
        }
        if (CanLongJump && !KeyJump)
        {
            CanLongJump = false;
        }
        Vector2 vector = ((LowGravityTime > 0f) ? new Vector2(-0.25f, 0.5f) : Vector2.one);
        if (Rigid.velocity.y < -5f)//落下
        {
            velocity.y = Physics2D.gravity.y * vector.x * 5.25f * Time.fixedDeltaTime * (float)numY + velocity.y * (float)numY * num2;
            Ani.SetFloat("VelocityY", velocity.y);
        }
        else if (Rigid.velocity.y <= 5f)//上升轉落下，延長滯空時間
        {
            velocity.y = Physics2D.gravity.y * vector.x * 2.25f * Time.fixedDeltaTime * (float)numY + velocity.y * (float)numY * num2;
            Ani.SetFloat("VelocityY", velocity.y);
        }
        else if (Rigid.velocity.y > 5f && KeyJump && CanLongJump)//上升時按住跳
        {
            velocity.y = Physics2D.gravity.y * vector.y * 5f * Time.fixedDeltaTime * (float)numY + velocity.y * (float)numY * num2;
            Ani.SetFloat("VelocityY", velocity.y);
        }
        else if (Rigid.velocity.y > 5f)//上升
        {
            velocity.y = Physics2D.gravity.y * vector.y * 15f * Time.fixedDeltaTime * (float)numY + velocity.y * (float)numY * num2;
            Ani.SetFloat("VelocityY", velocity.y);
        }
        if (numY == 0 || LowGravityTime > 0f)
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

                forceMovement.TimeUsed += Time.fixedDeltaTime * num2;

                float targetTime = forceMovement.Base.Curve.Evaluate(forceMovement.TimeUsed / forceMovement.Base.FinishTime);

                Vector3 vector2 = Vector3.Lerp(forceMovement.StartPosition, forceMovement.StartPosition + Vector3Utility.CacuFacing(forceMovement.Base.TargetDistance, Facing), targetTime);
                zero += vector2;

                if (forceMovement.TimeUsed >= forceMovement.Base.FinishTime)
                {
                    if (list == null)
                    {
                        list = new List<ForceMovement>();
                    }
                    list.Add(forceMovement);
                }
                
            }
            if (list != null)
            {
                foreach (ForceMovement item in list)
                {
                    StoredMoves.Remove(item);
                }
            }
            //Rigid.MovePosition(base.transform.position + zero * Time.fixedDeltaTime * num2);
            Rigid.MovePosition(zero);
            if (zero.x != 0f)
            {
                rigidbodyConstraints2D = RigidbodyConstraints2D.None;
            }
        }
        else if((bool)Player)
            Player.EvadeState.EvadeDistanceEffect.Stop();//停止位移時

        Rigid.constraints = rigidbodyConstraints2D | RigidbodyConstraints2D.FreezeRotation;
        Rigid.velocity = velocity;
        LastPos = base.transform.position;
    }

    public void CheckFace()
    {
        base.transform.GetChild(0).localScale = new Vector3(Mathf.Abs(base.transform.GetChild(0).localScale.x) * (float)Facing, base.transform.GetChild(0).localScale.y, 1f);
    }

    public bool TakeDamage(Damage _damage, float _HitStun = .25f, Character _attacker = null, bool isActionInterrupted = false, Vector2 _ClosestPoint = default)
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
            if ((bool)Player && Player.InvincibleState.InvincibleTime > 0 && !Blocking)
            {
                return false;
            }
            
            if (Blocking)
            {
                //防禦成功時間暫停
                //HitEffect.SetHitStun(false, false, .5f, false);
                //_attacker.HitEffect.SetHitStun(false, false, .5f, false);

                ((ActionBlockObj)NowAction).Block(this, _ClosestPoint);

                return false;
            }

            //SpriteRenderer component = base.gameObject.transform.GetChild(0).GetComponent<SpriteRenderer>();
            //DOTween.Sequence().Append(component.DOFade(1.75f, 0.1f));//.Append(component.DOFade(1f, 0.15f));
            //DOTween.Sequence().Append(component.DOColor(new Color(1f, 0.675f, 0.675f), 0.1f)).Append(component.DOColor(Color.white, 0.25f));
            //Debug.Log("Hit : " + base.gameObject.name);
            if (_damage.Type != DamageType.Bullet)
                LowGravityTime = 0.665f;
            HitEffect.SetHitStun(isActionInterrupted, ImmuneStunAction, _HitStun);
            //if ((bool)AITree)
            //{
            //    AITree.SendEvent("Attacked", (object)_attacker.transform);
            //    BehaviorManager.instance.Tick(AITree);
            //    AITree.DisableBehavior(pause: true);
            //    CancelInvoke("ResumeAI");
            //    Invoke("ResumeAI", 0.75f);
            //}


            if (isActing && isActionInterrupted)
            {
                NowAction.EndAction(this);

                if (StoredMoves.Count > 0)
                {
                    StoredMoves.Clear();
                }
            }
            if (!ImmuneInterruptAction)
            {
                AnimatorExtensions.RebindAndRetainParameter(Ani);
                //Ani.Rebind();
                Ani.Play("Attacked");
                Ani.Update(0f);
            }

            if ((bool)Player)
            {
                if (_damage.Type == DamageType.Normal)
                    AerutaDebug.i.Feedback.HittedCount++;
                if (_damage.Type == DamageType.Collision)
                    AerutaDebug.i.Feedback.CollisionCount++;

                //Player.Morph.Consume(Player.Morph.MorphProgress);

                if (Player.CatMode)
                    _damage.Amount *= 2;

                Instantiate(Player.HurtEffect, transform.position, Quaternion.identity, transform);
                HitEffect.SetGlobalSlowNextFrame(.5f, 0);

                Player.InvincibleState.Invincible();

                MarkManager.i.ClearMarkedTargets();

                Player.CanInput = false;
            }
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

    public virtual void SetAnimationIdle()
    {
        setAnimationIdle = true;

    }

    public virtual void Dead()
    {
        isDead = true;
        DOVirtual.Color(Renderer.skeleton.GetColor(), new Color(1, 1, 1, 0), 3f, (value) =>
        {
            Renderer.skeleton.SetColor(value);
        });
        AITree.enabled = false;
        base.gameObject.layer = 13;
        for (int i = 0; i < UnityEngine.Random.Range(2, 4); i++)
        {
            //UnityEngine.Object.Instantiate(GeneralPrefabSO.i.P_HealthShard, base.transform.position + new Vector3(0f, 1.25f), Quaternion.identity);
        }
        //base.gameObject.SetActive(value: false);
        StartAction(DeadAction);
        HurtBox.enabled = false;
        CollisionBlockMove.enabled = false;
    }

    public void TakeForce(Vector2 _Force, Vector2 _AddiForce)
    {
        
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
                //Airbrone = true;
            }
            //Debug.Log(string.Concat(Rigid.velocity, isActing.ToString()));
        }
        isKnockback = true;
        CanLongJump = false;
        Rigid.drag = 0f;


        HitEffect.SetTimeSlow(0.15f);
    }

    public void ResumeAI()
    {
        //AITree.EnableBehavior();
    }

    public int TryIsNotBlockedByCharacter()
    {
        int value = 0;

        BoxCollider2D component = GetComponent<BoxCollider2D>();
        RaycastHit2D[] raycastHit2D = Physics2D.RaycastAll(component.bounds.center, Vector2.right * Facing, component.bounds.extents.x + .1f, LayerMask.GetMask("CollisionBlockMove"));

        //if (raycastHit2D.Length <= 1)//只有射到自己，LayerMask是Character才啟用
        //{
        //    value = 1;
        //    return value;
        //}

        //if ((bool)Player && Player.InvincibleState.InvincibleTime > 0)//阻止玩家無敵時走過敵人
        {
            foreach (RaycastHit2D hit in raycastHit2D)
            {
                if (hit.collider.transform.parent.name != component.name) 
                {
                    if (hit.point.x >= hit.collider.bounds.max.x || hit.point.x <= hit.collider.bounds.min.x)
                    {
                        Debug.DrawLine(hit.point, component.bounds.center, Color.red, 2f);
                        value = 0;
                        return value;
                    }
                }
            }
        }

        Debug.DrawLine(component.bounds.center, component.bounds.center + (component.bounds.extents.x + .1f) * Vector3.right * Facing, Color.green, 2f);
        value = 1;
        return value;
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
    bool TakeDamage(Damage _damage, float _HitStun = .25f, Character _attacker = null, bool isActionInterrupted = false, Vector2 _ClosestPoint = default);
}

[Serializable]
public class TimedLink
{
    public ActionLink Base;

    public float LifeTimePassed;

    public TimedLink(ActionLink _base, float _lifeTimePassed = 0f)
    {
        Base = _base;
        LifeTimePassed = _lifeTimePassed;
    }
}

public class HittedGameObjectKey
{
    public int attackSpot;
    public GameObject gameObject;

    public HittedGameObjectKey(int _attackSpot, GameObject _gameObject)
    {
        attackSpot = _attackSpot;
        gameObject = _gameObject;
    }

    public class EqualityComparer : IEqualityComparer<HittedGameObjectKey>
    {
        public bool Equals(HittedGameObjectKey x, HittedGameObjectKey y)
        {
            return x.attackSpot == y.attackSpot && x.gameObject == y.gameObject;
        }

        public int GetHashCode(HittedGameObjectKey x)
        {
            return x.attackSpot + x.gameObject.GetHashCode();
        }
    }

}