using System.Collections;
using System.Collections.Generic;
using System.ComponentModel;
using TMPro;
using UnityEngine;
using UnityEngine.InputSystem;
using UnityEngine.SceneManagement;
using UnityEngine.UI;

public class PlayerMain : Character
{
    //玩家Input
    public InputActionAsset inputActionAsset;
    private InputActionMap playerAct;

    public static PlayerMain i;

    [HideInInspector]
    public MorphUser Morph;

    //[HideInInspector]
    //public PlayerSwing Swinger;

    private Slider ActionLinkTime;

    private Slider SilderHealth;

    private bool CanDash;

    public bool CanAttack;

    public List<InputKey> RestrictInput = new List<InputKey>();

    //public Interacter MyInteracter;

    public GameObject Platform;

    public bool CanInput;

    public float EvadeCooldown;

    public List<Image> Potions;

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
        //MyInteracter = GetComponentInChildren<Interacter>();
        Morph = GetComponent<MorphUser>();
        MorphUser.Local = Morph;
        //Swinger = GetComponent<PlayerSwing>();
        //Swinger.Main = this;
        //ActionLinkTime = GameObject.Find("ActionLinkTime").GetComponent<Slider>();
        SilderHealth = GameObject.Find("HealthBar").GetComponent<Slider>();
        TextInput = GameObject.Find("Input").GetComponent<TextMeshProUGUI>();
        Application.targetFrameRate = 120;

        inputActionAsset = GetComponent<PlayerInput>().actions;
        playerAct = inputActionAsset.FindActionMap("Player");
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
        if (Inputs.Contains(InputKey.Evade))
        {
            if (base.isActing && NowAction.Id != "Evade")
            {
                if (Morph.MorphCount > 0||true)//閃避更新
                {
                    if (Xinput != 0f)
                    {
                        Facing = ((Xinput > 0f) ? 1 : (-1));
                    }
                    StartAction(ActionLoader.i.Actions["Evade"]);
                    //Morph.Consume();
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
                StartAction(ActionLoader.i.Actions["Evade"]);
                Inputs.Clear();
                return;
            }
        }
        if (!base.isActing)
        {
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
            AerutaDebug.i.Feedback.EnergyRecoveryCount += NowAction.MorphRecoveryAdditionalByMark;
        }
    }

    public override void AttackLand()
    {
        base.AttackLand();
        if (base.isActing)
        {
            Morph.Add(NowAction.MorphRecovery);
            AerutaDebug.i.Feedback.EnergyRecoveryCount += NowAction.MorphRecovery;
        }
    }

    public override void OnEvading()
    {
        base.OnEvading();
        AerutaDebug.i.CallEffect(2);
        if (base.isActing)
        {
            Morph.Add(NowAction.EvadeEnergyRecovery);
        }
    }

    public override bool TryCastAction(ActionBaseObj _actionBaseObj, bool isShowMessage = true)
    {
        //Debug.Log("Try Cast " + _actionBaseObj.DisplayName);
        bool flag = true;
        if (flag && _actionBaseObj.Id != "Heal" && _actionBaseObj.MorphCost > 0f && Morph.TotalMorph < _actionBaseObj.MorphCost) 
        {
            flag = false;
            if (isShowMessage)
                SkillPopup.i.ShowMessage("No Energy !");
        }
        if (flag && _actionBaseObj.Id == "Heal" && _actionBaseObj.MorphCost > 0f && Potions.Count < _actionBaseObj.MorphCost)
        {
            flag = false;
            if (isShowMessage)
                SkillPopup.i.ShowMessage("No Potions !");
        }

        if (flag && _actionBaseObj.NeedButterfly && Butterfly.i.Cooldown > 0f)
        {
            flag = false;
            if (isShowMessage)
                SkillPopup.i.ShowMessage("Butterfly Not Ready !");
        }
        //if (flag && !_actionBaseObj.TryNewConditionPossible(this))有新的使用條件再用
        //{
        //    flag = false;
        //    if (isShowMessage)
        //        SkillPopup.i.ShowMessage("Butterfly Not Ready !");
        //}

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

    public override bool TryLink(string _Id, bool _forceSuccess)
    {
        bool result = false;
        foreach (ActionLink link in NowAction.Links)
        {
            if (link.PreviousId != "" && link.PreviousId != _Id)
                continue;
            if (((link.KeyArrow == InputKey.None || link.KeyArrow != InputKey.Up || playerAct.FindAction("Movement").ReadValue<Vector2>().y > 0.35f) && Inputs.Contains(link.Key1)) || _forceSuccess)
            {
                if (!TryCastAction(ActionLoader.i.Actions[link.LinkActionId]))
                    continue;

                StartAction(ActionLoader.i.Actions[link.LinkActionId]);
                result = true;
                Inputs.Clear();
                if (link.CanChangeFace && Xinput != 0f)
                {
                    Facing = ((Xinput > 0f) ? 1 : (-1));
                }
                //AerutaDebug.i.CallEffect(1);
                break;
            }
        }
        return result;
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
        if (!CanDash)
        {
            EvadeCooldown -= Time.deltaTime;
            if (EvadeCooldown < 0f)
            {
                EvadeCooldown = 1f;
                CanDash = true;
            }
        }
        if (!CanAttack && !base.isActing)
        {
            CanAttack = base.isGround;
        }
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
        if (playerAct.FindAction("Evade").WasPressedThisFrame() && (EvadeCooldown < .1f|| EvadeCooldown==1f))
        {
            TryInput(InputKey.Evade);
        }
        if (playerAct.FindAction("Burst").WasPressedThisFrame())
        {
            TryInput(InputKey.Burst);
        }
        if (playerAct.FindAction("Ult").WasPressedThisFrame())
        {
            TryInput(InputKey.Ult);
        }
        if (playerAct.FindAction("Burst").WasReleasedThisFrame())
        {
            TryInput(InputKey.BurstRelease);
            Inputs.Remove(InputKey.Burst);
        }
        if (playerAct.FindAction("Heal").WasPressedThisFrame())
        {
            TryInput(InputKey.Heal);
        }
        if (playerAct.FindAction("Mark").WasPressedThisFrame())
        {
            TryInput(InputKey.Mark);
        }
        if (playerAct.FindAction("UI").WasPressedThisFrame())
        {
            AerutaDebug.i.CloseUI();
        }
        Charging = playerAct.FindAction("Burst").IsPressed();
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
        SilderHealth.value = base.Health / HealthMax.Final;
    }

    private void OnTriggerEnter2D(Collider2D collision)
    {
        //if (collision.CompareTag("Lava"))
        //{
        //    //RoomManager.i.TeleportToSafePoint();
        //}
    }

    public void ResetDash()
    {
        CanDash = true;
    }
}
