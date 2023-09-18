using System.Collections;
using System.Collections.Generic;
using TMPro;
using UnityEngine;
using UnityEngine.InputSystem;
using UnityEngine.SceneManagement;
using UnityEngine.UI;

public class PlayerMain : Character
{
    private Rigidbody2D rb2D;

    //玩家Input
    public InputActionAsset inputActionAsset;
    private InputActionMap playerAct;

    private Vector2 inputVector;
    private bool isGrounded;


    [System.Serializable] public class HorizontalMovement
    {
        public float MaxSpeed;
        public float Acceleration;
        public float Deceleration;
        public float TurnAcceleration;
    }
    public HorizontalMovement horizontalMovement;

    [System.Serializable] public class Jump
    {
        public float JumpHeight;
        public float TakeoffVelocity;

        public float DownGravity;
        public bool ReleasedJump;

        public float TerminalVelocity;

        public float BufferTime;
        public float currentBufferTime;
        public float CoyoteTime;
        public float currentCoyoteTime;

        public List<GameObject> touchedGrounds = new List<GameObject>();
        public LayerMask GroundLayer;
    }
    public Jump jump;


    private void OnEnable()
    {
        playerAct.Enable();
    }
    private void OnDisable()
    {
        playerAct.Disable();
    }
    void Awake()
    {
        rb2D = GetComponent<Rigidbody2D>();

        inputActionAsset = GetComponent<PlayerInput>().actions;
        playerAct = inputActionAsset.FindActionMap("Player");

        isGrounded = true;
    }
    
    void Update()
    {
        inputVector = playerAct.FindAction("Movement").ReadValue<Vector2>();
        if (inputVector.x > -0.0001f && inputVector.x < 0.0001f)//校正搖桿只上下推時x軸會變成1.525879E-05的bug
            inputVector.x = 0;

        #region 跳躍
        if (jump.currentCoyoteTime > 0 && !isGrounded)
            jump.currentCoyoteTime = Mathf.Clamp(jump.currentCoyoteTime - Time.deltaTime, 0, jump.CoyoteTime);
        if (jump.currentBufferTime > 0)
            jump.currentBufferTime = Mathf.Clamp(jump.currentBufferTime - Time.deltaTime, 0, jump.BufferTime);

        if (playerAct.FindAction("Jump").IsPressed()) 
        {
            jump.currentBufferTime = jump.BufferTime;
        }
        if (jump.currentBufferTime > 0 && (jump.currentCoyoteTime > 0 || isGrounded))
        {
            rb2D.velocity = new Vector3(rb2D.velocity.x, jump.TakeoffVelocity);
            //isGrounded = true;
            jump.currentBufferTime = 0;
            jump.currentCoyoteTime = 0;
        }

        if (playerAct.FindAction("Jump").WasPressedThisFrame())
            jump.ReleasedJump = false;
        if (playerAct.FindAction("Jump").WasReleasedThisFrame())
            jump.ReleasedJump = true;

        #endregion
    }

    private void FixedUpdate()
    {
        float horizontalVelocity = 0;
        if (inputVector.x == 0)
        {
            //先把rb2D.velocity.x取絕對值做正數計算後再乘上rb2D.velocity.x原本的正負，這樣做負數計算不會出bug
            horizontalVelocity = Sign(rb2D.velocity.x) * Mathf.Clamp(Mathf.Abs(rb2D.velocity.x) - horizontalMovement.Deceleration * Time.deltaTime, 0, horizontalMovement.MaxSpeed);
        }
        else if (inputVector.x != 0 && rb2D.velocity.x != 0 && Sign(inputVector.x) != Sign(rb2D.velocity.x)) //輸入方向 不等於 腳色正在移動的方向
        {
            horizontalVelocity = Sign(rb2D.velocity.x) * Mathf.Clamp(Mathf.Abs(rb2D.velocity.x) - horizontalMovement.TurnAcceleration * Time.deltaTime, 0, horizontalMovement.MaxSpeed);
        }
        else //輸入方向 等於 腳色正在移動的方向
        {
            horizontalVelocity = Mathf.Clamp(rb2D.velocity.x + Sign(inputVector.x) * horizontalMovement.Acceleration * Time.deltaTime, -horizontalMovement.MaxSpeed, horizontalMovement.MaxSpeed);
        }

        float verticalVelocity = rb2D.velocity.y + Physics2D.gravity.y * Time.deltaTime;
        if (rb2D.velocity.y <= jump.TerminalVelocity)
            verticalVelocity = jump.TerminalVelocity;
        else if (rb2D.velocity.y > 0 && jump.ReleasedJump)
            verticalVelocity += jump.DownGravity * Time.deltaTime;

        rb2D.velocity = new Vector3(horizontalVelocity, verticalVelocity);
    }

    static float Sign(float number)
    {
        return number < 0 ? -1 : (number > 0 ? 1 : 0);
    }

    #region child trigger

    #endregion

    private void OnCollisionEnter2D(Collision2D collision)
    {
        if (1 << collision.gameObject.layer == jump.GroundLayer.value && collision.contacts[0].normal == Vector2.up)
        {
            if (!jump.touchedGrounds.Contains(collision.gameObject))
                jump.touchedGrounds.Add(collision.gameObject);

            isGrounded = true;
            jump.currentCoyoteTime = jump.CoyoteTime;
        }
    }

    private void OnCollisionStay2D(Collision2D collision)
    {
        if (1 << collision.gameObject.layer == jump.GroundLayer.value && collision.contacts[0].normal == Vector2.up && rb2D.velocity.y == 0 && isGrounded == false)
        {
            if (!jump.touchedGrounds.Contains(collision.gameObject))
                jump.touchedGrounds.Add(collision.gameObject);

            isGrounded = true;
            jump.currentCoyoteTime = jump.CoyoteTime;
        }
    }

    private void OnCollisionExit2D(Collision2D collision)
    {
        if (1 << collision.gameObject.layer == jump.GroundLayer.value)
        {
            jump.touchedGrounds.Remove(collision.gameObject);

            if (jump.touchedGrounds.Count == 0)
                isGrounded = false;
        }
    }



    public static PlayerMain i;

    [HideInInspector]
    public OrbUser Orb;

    //[HideInInspector]
    //public PlayerSwing Swinger;

    private Slider ActionLinkTime;

    private Slider SilderHealth;

    private bool CanDash;

    public bool CanAttack;

    public List<InputKey> RestrictInput = new List<InputKey>();

    public Interacter MyInteracter;

    public GameObject Platform;

    public override void OnAwake()
    {
        base.OnAwake();
        i = this;
        isLocal = true;
        MyInteracter = GetComponentInChildren<Interacter>();
        Orb = GetComponent<OrbUser>();
        OrbUser.Local = Orb;
        //Swinger = GetComponent<PlayerSwing>();
        //Swinger.Main = this;
        ActionLinkTime = GameObject.Find("ActionLinkTime").GetComponent<Slider>();
        SilderHealth = GameObject.Find("HealthBar").GetComponent<Slider>();
        TextInput = GameObject.Find("Input").GetComponent<TextMeshProUGUI>();
        Application.targetFrameRate = 120;
    }

    private void Start()
    {
        OrbListDisplayer.i.Target = Orb;
        Debug.Log(Input.GetJoystickNames().Length);
    }

    public override void ProcessInput()
    {
        if (Inputs.Contains(InputKey.Skill))
        {
            ActionBaseObj actionBaseObj = ActionLoader.i.Actions[101u];
            switch (InputUtli.GetHighestAxis(Xinput, Yinput))
            {
                case InputKey.Left:
                case InputKey.Right:
                    actionBaseObj = ActionLoader.i.Actions[102u];
                    break;
                case InputKey.Down:
                    actionBaseObj = ActionLoader.i.Actions[103u];
                    break;
                case InputKey.Up:
                    actionBaseObj = ActionLoader.i.Actions[104u];
                    break;
            }
            if (TryCastAction(actionBaseObj))
            {
                StartAction(actionBaseObj);
            }
            Inputs.Clear();
        }
        if (Inputs.Contains(InputKey.Dash))
        {
            if (base.isActing && NowAction.Id != 4)
            {
                if (Orb.OrbCount > 0)
                {
                    if (Xinput != 0f)
                    {
                        Facing = ((Xinput > 0f) ? 1 : (-1));
                    }
                    StartAction(ActionLoader.i.Actions[4u]);
                    Orb.Consume();
                    CanDash = false;
                    Inputs.Clear();
                }
                else
                {
                    Inputs.Clear();
                }
                return;
            }
            if (CanDash)
            {
                CanDash = false;
                CanAttack = true;
                StartAction(ActionLoader.i.Actions[4u]);
                Inputs.Clear();
                return;
            }
        }
        if (!base.isActing)
        {
            if (Inputs.Contains(InputKey.Attack) && CanAttack)
            {
                StartAction(ActionLoader.i.Actions[0u]);
                Inputs.Clear();
            }
            else if (Inputs.Contains(InputKey.ExploreAction))
            {
                switch (InputUtli.GetHighestAxis(Xinput, Yinput))
                {
                    case InputKey.Up:
                        Object.Instantiate(Platform, base.transform.position + Vector3Utli.CacuFacing(new Vector3(2.25f, 2.75f), Facing), Quaternion.identity);
                        break;
                    default:
                        //Swinger.StartHook();
                        break;
                    case InputKey.Down:
                    case InputKey.Left:
                    case InputKey.Right:
                        break;
                }
                Inputs.Clear();
            }
        }
        //if (Swinger.isSwinging && KeyJumpJust)
        //{
        //    Swinger.CutHook();
        //}
    }

    public override void AttackLand()
    {
        base.AttackLand();
        if (base.isActing)
        {
            Orb.Add(NowAction.OrbRecovery);
        }
    }

    public override bool TryCastAction(ActionBaseObj _actionBaseObj)
    {
        Debug.Log("Try Cast " + _actionBaseObj.DisplayName);
        bool flag = true;
        if (flag && _actionBaseObj.OrbCost > 0f && Orb.TotalOrb < _actionBaseObj.OrbCost)
        {
            flag = false;
            SkillPopup.i.ShowMessage("動力不足 !");
        }
        if (flag && base.isActing)
        {
            flag = (_actionBaseObj.InterruptSameLevel ? (NowAction.InterruptLevel <= _actionBaseObj.InterruptLevel) : (NowAction.InterruptLevel < _actionBaseObj.InterruptLevel));
            Debug.Log("Action Interrupt " + flag);
        }
        if (flag && _actionBaseObj.GroundOnly && !base.isGround)
        {
            flag = false;
            SkillPopup.i.ShowMessage(_actionBaseObj.DisplayName + "只能在地面使用 !");
        }
        return flag;
    }

    public override void StartAction(ActionBaseObj _actionBaseObj)
    {
        TextMeshProUGUI textInput = TextInput;
        textInput.text = textInput.text + _actionBaseObj.AnimationKey + " > ";
        Swinger.CutHook();
        base.StartAction(_actionBaseObj);
        if (_actionBaseObj.Id == 0)
        {
            CanAttack = false;
        }
        Orb.Consume(_actionBaseObj.OrbCost);
    }

    public override void Dead()
    {
        SceneManager.LoadScene(0);
    }

    public override void TryInput(InputKey _InputKey)
    {
        if (RestrictInput.Count <= 0 || RestrictInput.Contains(_InputKey))
        {
            base.TryInput(_InputKey);
        }
    }

    public override bool TryLink()
    {
        bool result = false;
        foreach (ActionLink link in NowAction.Links)
        {
            if ((link.KeyArrow == InputKey.None || link.KeyArrow != InputKey.Up || Input.GetAxis("Vertical") > 0.35f) && Inputs.Contains(link.Key1))
            {
                StartAction(ActionLoader.i.Actions[link.LinkAcionId]);
                result = true;
                Inputs.Clear();
                if (link.CanChangeFace && Xinput != 0f)
                {
                    Facing = ((Xinput > 0f) ? 1 : (-1));
                }
                AerutaDebug.i.CallEffect(1);
                break;
            }
        }
        return result;
    }

    public override void OnUpdate()
    {
        base.OnUpdate();
        if (DialogHandler.i.isDialoging)
        {
            return;
        }
        if (!CanDash && !base.isActing)
        {
            CanDash = base.isGround;
        }
        if (!CanAttack && !base.isActing)
        {
            CanAttack = base.isGround;
        }
        KeyJump = Input.GetButton("Jump");
        bool flag = Ani.GetCurrentAnimatorStateInfo(0).IsTag("Immobile");
        if (Input.GetButtonDown("Jump") && !flag)
        {
            KeyJumpJust = true;
        }
        Xinput = (flag ? 0f : Input.GetAxis("Horizontal"));
        Yinput = Input.GetAxis("Vertical");
        Orb.Drive = Input.GetButton("Drive");
        if (Input.GetButton("Attack"))
        {
            bool buttonDown = Input.GetButtonDown("Attack");
            if (!MyInteracter.TryInteract(!buttonDown) && buttonDown)
            {
                TryInput(InputKey.Attack);
            }
        }
        if (Input.GetButtonDown("Evade"))
        {
            TryInput(InputKey.Dash);
        }
        if (Input.GetButtonDown("Skill"))
        {
            TryInput(InputKey.Skill);
        }
        if (Input.GetKeyDown(KeyCode.A))
        {
            TryInput(InputKey.ExploreAction);
        }
        Charging = Input.GetButton("Skill");
        if (base.isActing)
        {
            ActionLinkTime.maxValue = NowAction.LinkKey;
            ActionLinkTime.value = ActionState.Frame;
        }
        else
        {
            ActionLinkTime.value = 0f;
        }
        SilderHealth.value = base.Health / HealthMax.Final;
    }

    private void OnTriggerEnter2D(Collider2D collision)
    {
        if (collision.CompareTag("Lava"))
        {
            RoomManager.i.TeleportToSafePoint();
        }
    }

    public void ResetDash()
    {
        CanDash = true;
    }
}
