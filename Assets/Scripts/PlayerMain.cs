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
    public OrbUser Orb;

    //[HideInInspector]
    //public PlayerSwing Swinger;

    private Slider ActionLinkTime;

    private Slider SilderHealth;

    private bool CanDash;

    public bool CanAttack;

    public List<InputKey> RestrictInput = new List<InputKey>();

    //public Interacter MyInteracter;

    public GameObject Platform;

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
        Orb = GetComponent<OrbUser>();
        OrbUser.Local = Orb;
        //Swinger = GetComponent<PlayerSwing>();
        //Swinger.Main = this;
        ActionLinkTime = GameObject.Find("ActionLinkTime").GetComponent<Slider>();
        SilderHealth = GameObject.Find("HealthBar").GetComponent<Slider>();
        TextInput = GameObject.Find("Input").GetComponent<TextMeshProUGUI>();
        Application.targetFrameRate = 120;

        inputActionAsset = GetComponent<PlayerInput>().actions;
        playerAct = inputActionAsset.FindActionMap("Player");
    }

    private void Start()
    {
        OrbListDisplayer.i.Target = Orb;
        //Debug.Log(Input.GetJoystickNames().Length);
    }

    public override void ProcessInput()
    {
        //if (Inputs.Contains(InputKey.Burst))
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
        if (Inputs.Contains(InputKey.Evade))
        {
            if (base.isActing && NowAction.Id != "Evade")
            {
                if (Orb.OrbCount > 0)
                {
                    if (Xinput != 0f)
                    {
                        Facing = ((Xinput > 0f) ? 1 : (-1));
                    }
                    StartAction(ActionLoader.i.Actions["Evade"]);
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
            if (Inputs.Contains(InputKey.Gun) && CanAttack)
            {
                if (TryCastAction(ActionLoader.i.Actions["Gun1"]))
                    StartAction(ActionLoader.i.Actions["Gun1"]);

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

    public override bool TryCastAction(ActionBaseObj _actionBaseObj, bool isShowMessage = true)
    {
        Debug.Log("Try Cast " + _actionBaseObj.DisplayName);
        bool flag = true;
        if (flag && _actionBaseObj.OrbCost > 0f && Orb.TotalOrb < _actionBaseObj.OrbCost)
        {
            flag = false;
            if (isShowMessage)
                SkillPopup.i.ShowMessage("No Energy !");
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
        TextMeshProUGUI textInput = TextInput;
        textInput.text = textInput.text + _actionBaseObj.AnimationKey + " > ";
        //Swinger.CutHook();
        base.StartAction(_actionBaseObj);
        //if (_actionBaseObj.Id == 0)
        //{
        //    CanAttack = false;
        //}
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

    public override bool TryLink(string _Id)
    {
        bool result = false;
        foreach (ActionLink link in NowAction.Links)
        {
            if (link.PreviousId != "" && link.PreviousId != _Id)
                continue;
            if ((link.KeyArrow == InputKey.None || link.KeyArrow != InputKey.Up || playerAct.FindAction("Movement").ReadValue<Vector2>().y > 0.35f) && Inputs.Contains(link.Key1))
            {
                if (!TryCastAction(ActionLoader.i.Actions[link.LinkAcionId], false))
                    continue;

                StartAction(ActionLoader.i.Actions[link.LinkAcionId]);
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
        if (!CanDash && !base.isActing)
        {
            CanDash = base.isGround;
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
        Xinput = (flag || !TryCanForward() ? 0f : playerAct.FindAction("Movement").ReadValue<Vector2>().x);
        Yinput = playerAct.FindAction("Movement").ReadValue<Vector2>().y;
        Orb.Drive = playerAct.FindAction("Hint_Energy").IsPressed();
        if (playerAct.FindAction("Claw").WasPressedThisFrame())
        {
            //bool buttonDown = Input.GetButtonDown("Attack");
            //if (!MyInteracter.TryInteract(!buttonDown) && buttonDown)
            //{
                TryInput(InputKey.Claw);
            //}
        }
        if (playerAct.FindAction("Evade").WasPressedThisFrame())
        {
            TryInput(InputKey.Evade);
        }
        if (playerAct.FindAction("Burst").WasPressedThisFrame())
        {
            TryInput(InputKey.Burst);
        }
        if (playerAct.FindAction("Gun").WasPressedThisFrame())
        {
            TryInput(InputKey.Gun);
        }
        Charging = playerAct.FindAction("Burst").IsPressed();
        if (base.isActing)
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
            //RoomManager.i.TeleportToSafePoint();
        }
    }

    public void ResetDash()
    {
        CanDash = true;
    }

    public bool TryCanForward()
    {
        BoxCollider2D component = GetComponent<BoxCollider2D>();
        RaycastHit2D raycastHit2D = Physics2D.Raycast(component.bounds.center, Vector2.right * Facing, component.bounds.extents.x + .1f, LayerMask.GetMask("Character"));
        if (raycastHit2D.collider != null && raycastHit2D.collider.IsTouching(component)) 
        {
            Debug.DrawLine(raycastHit2D.point, component.bounds.center, Color.red, 2f);
            return false;
        }
        Debug.DrawLine(component.bounds.center, component.bounds.center + (component.bounds.extents.x + .1f) * Vector3.right * Facing, Color.green, 2f);
        return true;
    }
}
