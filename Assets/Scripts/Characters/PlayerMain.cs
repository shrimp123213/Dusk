using System.Collections;
using System.Collections.Generic;
using System.ComponentModel;
using System.Linq;
using TMPro;
using UnityEngine;
using UnityEngine.InputSystem;
using UnityEngine.SceneManagement;
using UnityEngine.UI;
using static Pieta;

public class PlayerMain : Character
{
    //玩家Input
    public InputActionAsset inputActionAsset;
    private InputActionMap playerAct;

    public static PlayerMain i;

    [HideInInspector]
    public MorphUser Morph;

    [HideInInspector]
    public EvadeState EvadeState;

    [HideInInspector]
    public InvincibleState InvincibleState;

    public ShockWaveManager shockWaveManager;

    //[HideInInspector]
    //public PlayerSwing Swinger;

    private Slider ActionLinkTime;

    private Slider SliderHealthTop;
    private Slider SliderHealthBottom;

    private float topMoveSpeed;
    private float bottomMoveSpeed;

    private float lastHealth;

    private float waitSliderHealthMove;

    private bool CanDash;

    public bool CanAttack;

    public List<InputKey> RestrictInput = new List<InputKey>();

    //public Interacter MyInteracter;

    public GameObject Platform;

    public bool CanInput;

    public float DashCooldown;

    public List<Image> Potions;

    public GameObject HurtEffect;

    public GameObject DoubleJumpEffect;

    public Vector2 ButterflyPos;

    private void OnEnable()
    {
        playerAct.Enable();
    }
    private void OnDisable()
    {
        playerAct.Disable();
    }


    public override void OnAwake()
    {
        base.OnAwake();
        i = this;
        isLocal = true;
        EvadeState = GetComponent<EvadeState>();
        InvincibleState = GetComponent<InvincibleState>();
        //MyInteracter = GetComponentInChildren<Interacter>();
        Morph = GetComponent<MorphUser>();
        MorphUser.Local = Morph;
        //Swinger = GetComponent<PlayerSwing>();
        //Swinger.Main = this;
        //ActionLinkTime = GameObject.Find("ActionLinkTime").GetComponent<Slider>();
        SliderHealthTop = GameObject.Find("HealthTop").GetComponent<Slider>();
        SliderHealthBottom = GameObject.Find("HealthBottom").GetComponent<Slider>();
        TextInput = GameObject.Find("Input").GetComponent<TextMeshProUGUI>();
        Application.targetFrameRate = 120;

        inputActionAsset = GetComponent<PlayerInput>().actions;
        playerAct = inputActionAsset.FindActionMap("Player");

        topMoveSpeed = .2f;
        bottomMoveSpeed = .2f;
    }

    private void Start()
    {
        MorphListDisplayer.i.Target = Morph;
        //Debug.Log(Input.GetJoystickNames().Length);
    }

    public override void ProcessInput()
    {
        //if (Inputs.Contains(InputKey.Burst))//方向攻擊
        //{
        //    ActionBaseObj actionBaseObj = ActionLoader.i.Actions[101u];
        //    switch (InputUtli.GetHighestAxis(Xinput, Yinput))
        //    {
        //        case InputKey.Left:
        //        case InputKey.Right:
        //            actionBaseObj = ActionLoader.i.Actions[102u];
        //            break;
        //        case InputKey.Down:
        //            actionBaseObj = ActionLoader.i.Actions[103u];
        //            break;
        //        case InputKey.Up:
        //            actionBaseObj = ActionLoader.i.Actions[104u];
        //            break;
        //    }
        //    if (TryCastAction(actionBaseObj))
        //    {
        //        StartAction(actionBaseObj);
        //    }
        //    Inputs.Clear();
        //}
        if (HitEffect.HitStun > 0)
        {
            Inputs.Clear();
            return;
        }
        //if (Xinput != 0 && base.isActing && (NowAction.Id == "Claw1" || NowAction.Id == "Claw2" || NowAction.Id == "Claw3" || NowAction.Id == "Claw4")) 攻擊時向後走可以取消攻擊，bug
        //{
        //    NowAction.EndAction(this);
        //    Inputs.Remove(InputKey.Claw);
        //}
        if (Inputs.Contains(InputKey.Dash))
        {
            if (!base.isActing || (base.isActing && NowAction.Id != "Dash" && NowAction.Id != "Pieta"))
            {
                if (!Blocking)
                {
                    if (Xinput != 0f)
                    {
                        Facing = ((Xinput > 0f) ? 1 : (-1));
                    }

                    StartAction(ActionLoader.i.Actions["Dash"]);

                    //Morph.Consume();
                    //CanDash = false;

                    Inputs.Clear();
                }
            }
        }
        if (!base.isActing)
        {
            if (Inputs.Contains(InputKey.Pieta))
            {
                if (TryCastAction(ActionLoader.i.Actions["Pieta"]))
                {
                    StartAction(ActionLoader.i.Actions["Pieta"]);
                }
                Inputs.Clear();
            }
            if (Inputs.Contains(InputKey.Block))
            {
                StartAction(ActionLoader.i.Actions["Block"]);
                Inputs.Clear();
            }
            if (Inputs.Contains(InputKey.Claw) && CanAttack)
            {
                StartAction(ActionLoader.i.Actions["Claw1"]);
                Inputs.Clear();
            }
            //if (Inputs.Contains(InputKey.Ult) && CanAttack)
            //{
            //    if (TryCastAction(ActionLoader.i.Actions["Penetrate"]))
            //        StartAction(ActionLoader.i.Actions["Penetrate"]);
            //
            //    Inputs.Clear();
            //}
            if (Inputs.Contains(InputKey.Heal))
            {
                if (TryCastAction(ActionLoader.i.Actions["Heal"]))
                {
                    StartAction(ActionLoader.i.Actions["Heal"]);
                    Potions[Potions.Count - 1].enabled = false;
                    Potions.RemoveAt(Potions.Count - 1);
                    AerutaDebug.i.Feedback.HealCount++;
                }
                Inputs.Clear();
            }
        }
    }

    public override void TriggerMark()
    {
        base.TriggerMark();
        if (base.isActing)
        {
            Morph.Add(NowAction.MorphRecoveryAdditionalByMark);
        }
    }

    public override void AttackLand()
    {
        base.AttackLand();
        if (base.isActing)
        {
            Morph.Add(NowAction.MorphRecovery);
        }
    }

    public override void OnEvading()
    {
        base.OnEvading();
        //AerutaDebug.i.CallEffect(2);
        /*if (base.isActing && !EvadeState.IsRewarded)
        {
            EvadeState.IsRewarded = true;
            Morph.Add(NowAction.EvadeEnergyRecovery);
            Instantiate(EvadeState.EvadeSuccessEffect, transform.position, Quaternion.identity, transform); 
            HitEffect.SetGlobalSlow(.5f, 1);
            AerutaDebug.i.Feedback.EvadeCount++;
        }*/
    }

    public override bool TryCastAction(ActionBaseObj _actionBaseObj, bool isShowMessage = true)
    {
        //Debug.Log("Try Cast " + _actionBaseObj.DisplayName);
        bool flag = true;
        if (flag && _actionBaseObj.Id != "Heal" && _actionBaseObj.Id != "Pieta" && _actionBaseObj.MorphCost > 0f && Morph.TotalMorph < _actionBaseObj.MorphCost) 
        {
            flag = false;
            if (isShowMessage)
                SkillPopup.i.ShowMessage("No Energy !");
        }
        if (flag && _actionBaseObj.Id == "Heal" && Potions.Count <= 0)
        {
            flag = false;
            if (isShowMessage)
                SkillPopup.i.ShowMessage("No Potions !");
        }

        if (flag && _actionBaseObj.Id == "Pieta" && _actionBaseObj.MorphCost > 0f && (Morph.MorphCount < _actionBaseObj.MorphCost || !Pieta.i.CheckPietaAttack(this)))
        {
            flag = false;
        }

        //if (flag && base.isActing)
        //{
        //    flag = (_actionBaseObj.InterruptSameLevel ? (NowAction.InterruptLevel <= _actionBaseObj.InterruptLevel) : (NowAction.InterruptLevel < _actionBaseObj.InterruptLevel));
        //    Debug.Log("Action Interrupt " + flag);
        //}
        if (flag && _actionBaseObj.GroundOnly && !base.isGround)
        {
            flag = false;
            if (isShowMessage)
                SkillPopup.i.ShowMessage(_actionBaseObj.DisplayName + "只能在地面使用 !");
        }
        return flag;
    }

    public override void StartAction(ActionBaseObj _actionBaseObj)
    {
        //TextMeshProUGUI textInput = TextInput;
        //if ((_actionBaseObj.AnimationKey.Contains("Claw") || _actionBaseObj.AnimationKey.Contains("Burst")) && textInput.text != "")
        //    textInput.text = textInput.text + "\n";
        //textInput.text = textInput.text + _actionBaseObj.AnimationKey + " -> ";
        //Swinger.CutHook();
        base.StartAction(_actionBaseObj);
        //if (_actionBaseObj.Id == 0)
        //{
        //    CanAttack = false;
        //}
        //Morph.Consume(_actionBaseObj.MorphCost, true);
    }

    public override void Dead()
    {
        Time.timeScale = 0f;
        AerutaDebug.i.ShowStatistics();
    }

    public override void TryInput(InputKey _InputKey)
    {
        if (RestrictInput.Count <= 0 || RestrictInput.Contains(_InputKey))
        {
            base.TryInput(_InputKey);
        }
    }

    public override bool TryLink(ActionLink link, bool _forceSuccess = false)
    {
        if (!ActionState.IsInLifeTime(link.Frame, link.LifeTime) || StoredMoves.Count > 0)
        {
            return false;
        }

        if (Inputs.Contains(link.Key1) || _forceSuccess)
        {
            if (!TryCastAction(ActionLoader.i.Actions[link.LinkActionId]))
                return false;

            if (link.CanChangeFace && Xinput != 0f)
            {
                Facing = ((Xinput > 0f) ? 1 : (-1));
            }

            StartAction(ActionLoader.i.Actions[link.LinkActionId]);
            
            Inputs.Clear();
            
            //AerutaDebug.i.CallEffect(1);
            return true;
        }
        return false;
    }

    public override void OnUpdate()
    {
        base.OnUpdate();
        //if (DialogHandler.i.isDialoging)
        //{
        //    return;
        //}
        //if (!CanDash && !base.isActing)
        //{
        //    CanDash = base.isGround;
        //}
        //if (!CanDash)
        //{
        //    DashCooldown -= Time.deltaTime;
        //    if (DashCooldown < 0f)
        //    {
        //        //DashCooldown = 1f;
        //        CanDash = true;
        //    }
        //}
        if (!CanAttack && !base.isActing)
        {
            CanAttack = base.isGround;
        }
        if (CanInput)
        {
            KeyJump = playerAct.FindAction("Jump").IsPressed();
            bool flag = Ani.GetCurrentAnimatorStateInfo(0).IsTag("Immobile");
            if (playerAct.FindAction("Jump").WasPressedThisFrame() && !flag)
            {
                KeyJumpJust = true;
            }
            Xinput = (flag ? 0f : playerAct.FindAction("Movement").ReadValue<Vector2>().x);
            Yinput = playerAct.FindAction("Movement").ReadValue<Vector2>().y;
            Morph.Drive = playerAct.FindAction("Hint_Energy").IsPressed();
            if (playerAct.FindAction("Claw").WasPressedThisFrame())
            {
                //bool buttonDown = Input.GetButtonDown("Attack");
                //if (!MyInteracter.TryInteract(!buttonDown) && buttonDown)
                //{
                TryInput(InputKey.Claw);
                //}
            }
            if (playerAct.FindAction("Dash").WasPressedThisFrame() && (DashCooldown < .1f || DashCooldown == 1f))
            {
                TryInput(InputKey.Dash);
            }
            if (playerAct.FindAction("Pieta").WasPressedThisFrame())
            {
                TryInput(InputKey.Pieta);
            }
            if (playerAct.FindAction("Heal").WasPressedThisFrame())
            {
                TryInput(InputKey.Heal);
            }
            if (playerAct.FindAction("UI").WasPressedThisFrame())
            {
                AerutaDebug.i.CloseUI();
            }
            if (playerAct.FindAction("Block").WasPressedThisFrame())
            {
                TryInput(InputKey.Block);
            }
            //if (playerAct.FindAction("UseButterfly").WasPressedThisFrame())
            //{
            //    //TryInput(InputKey.UseButterfly);
            //    ButterflyManager.i.StartMove();
            //}
            //Charging = playerAct.FindAction("Burst").IsPressed();
        }

        if (base.isActing)
        {
            if (ActionLinkTime != null)
            {
                if (NowAction.Links.Count <= 0)
                {
                    ActionLinkTime.value = 0f;
                }
                else
                {
                    ActionLinkTime.maxValue = ActionState.TotalFrame;// - NowAction.Links[0].Frame;
                    ActionLinkTime.value = ActionState.Frame;// - NowAction.Links[0].Frame;
                }
            }
            
        }
        else
        {
            if (ActionLinkTime != null)
                ActionLinkTime.value = 0f;
        }

        if (TimedLinks.Count > 0)
        {
            bool _Marked = false;
            foreach (var _link in TimedLinks.OrderBy(w => w.Base.KeyArrow != InputKey.None)) 
            {
                if (TryLink(_link.Base)) { _Marked = false; break; }
                if (Mathf.Approximately(_link.Base.LifeTime, -1)) { continue; }
                if (NowAction == null) { _link.LifeTimePassed += Time.fixedDeltaTime; }
                if (_link.LifeTimePassed >= _link.Base.LifeTime)  { _Marked = true; }
            }

            if (_Marked) { TimedLinks.RemoveAll(w => w.LifeTimePassed >= w.Base.LifeTime); }
        }

        if (lastHealth != base.Health)
            HealthChenged();

        if (waitSliderHealthMove <= 0f)
        {
            SliderHealthTop.value = Mathf.MoveTowards(SliderHealthTop.value, base.Health / HealthMax.Final, topMoveSpeed * Time.deltaTime);
            SliderHealthBottom.value = Mathf.MoveTowards(SliderHealthBottom.value, base.Health / HealthMax.Final, bottomMoveSpeed * Time.deltaTime);
        }
        else
            waitSliderHealthMove -= Time.deltaTime;
    }

    public void HealthChenged()
    {
        if ((float)SliderHealthTop.value > (float)(base.Health / HealthMax.Final))
            SliderHealthTop.value = base.Health / HealthMax.Final;

        if ((float)SliderHealthBottom.value < (float)(base.Health / HealthMax.Final))
            SliderHealthBottom.value = base.Health / HealthMax.Final;

        lastHealth = base.Health;

        if (!(isActing && NowAction.Id == "Heal"))
            waitSliderHealthMove = .5f;
    }

    private void OnTriggerStay2D(Collider2D collision)
    {
        //if (collision.CompareTag("Lava"))
        //{
        //    //RoomManager.i.TeleportToSafePoint();
        //}

        if (collision.gameObject.layer == LayerMask.NameToLayer("CollisionDamageBox") && !Evading)
        {
            Character _attacker = collision.transform.parent.GetComponent<Character>();
            bool num = TakeDamage(new Damage(_attacker.Attack.Final, DamageType.Collision), .25f, _attacker, !ImmuneInterruptAction);
            if(num) TakeForce(Vector3Utility.CacuFacing(Vector2.right * 15f, Vector3Utility.GetFacingByPos(_attacker.transform, transform)), new Vector2(0f, 0f));

        }
    }

    public void ResetDash()
    {
        CanDash = true;
    }
}
