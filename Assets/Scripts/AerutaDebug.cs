using DG.Tweening;
using UnityEngine;
using UnityEngine.SceneManagement;
using UnityEngine.UI;
using TMPro;
using BehaviorDesigner.Runtime;


public class AerutaDebug : MonoBehaviour
{
    public static AerutaDebug i;

    public RectTransform[] rectTransforms;

    public Sequence[] Sequences = new Sequence[4];

    public GameObject PrefabClap;


    public Feedback Feedback = new Feedback();
    public GameObject Statistics;
    public float StartGameTime;

    public GameObject ChargeEffect;
    public GameObject BlockEffectNormal;
    public GameObject BlockEffectPerfect;
    public GameObject BloodEffect;
    public GameObject PenetrateTrail;
    public GameObject ClawEffect;
    public GameObject BlockFlashYellow;
    public GameObject BlockFlashBlue;
    public GameObject EvadeFinishCooldownEffect;
    public GameObject TransformationEffect;
    public GameObject PlayerAttackLandEffect;

    public ParticleSystem Leaf;

    public Character Boss1;

    public Image ControlGamepad, ControlKeyboard;

    public Contact contact;

    private void Awake()
    {
        i = this;

        //if (ControlGamepad.enabled || ControlKeyboard.enabled)
            Time.timeScale = 0f;
    }

    public void CallEffect(int num)//��ܥ��������ĤH�B�{�צ��\��UI
    {
        if (Sequences[num] != null && Sequences[num].active)
        {
            Sequences[num].Kill();
            rectTransforms[num].DOAnchorPosX(-500f, 0f);
        }
        Sequences[num] = DOTween.Sequence();
        Sequences[num].Append(rectTransforms[num].DOAnchorPosX(25f, 0.1f)).Append(rectTransforms[num].DOAnchorPosX(20f, 0.2f)).AppendInterval(0.35f)
            .Append(rectTransforms[num].DOAnchorPosX(-500f, 0f));
    }

    private void Update()
    {
        if (Input.GetKeyDown(KeyCode.Q))
        {
            RectTransform component = GameObject.Find("TimeDateIMG").GetComponent<RectTransform>();
            component.sizeDelta = ((component.sizeDelta.y == 500f) ? new Vector2(200f, 130f) : new Vector2(200f, 500f));
        }
        if (Input.GetKeyDown(KeyCode.F3))
        {
            PlayerMain.i.Morph.Add(10f);
        }
        if (Input.GetKeyDown(KeyCode.F4))
        {
            Character component2 = Object.Instantiate(Resources.Load<GameObject>("Character/EnemyA/Enemy01"), PlayerMain.i.transform.position, Quaternion.identity).GetComponent<Character>();
            component2.Health = 100f;
            component2.Speed.BaseSet(0f);
        }

        if (Input.GetKeyDown(KeyCode.F5))
        {
            SceneManager.LoadScene(0);
        }

        if (Input.GetKeyDown(KeyCode.Alpha0))
        {
            AerutaDebug.i.Boss1.Ani.speed = 0f;
            AerutaDebug.i.Boss1.AITree.enabled = false;
        }
        if (Input.GetKeyDown(KeyCode.Alpha9))
        {
            AerutaDebug.i.Boss1.Ani.speed = 1f;
            AerutaDebug.i.Boss1.AITree.enabled = true;
        }

        if (Input.GetKeyDown(KeyCode.F1))
        {
            contact.Skip();
        }
    }

    public void InsClap(Vector3 _v3)
    {
        Object.Destroy(Object.Instantiate(PrefabClap, _v3, Quaternion.identity), 1.5f);
    }


    public void ShowStatistics()
    {
        Statistics.SetActive(true);
        Feedback.PlayTime = Time.unscaledTime - StartGameTime;
        Statistics.transform.GetChild(0).GetComponent<TMP_Text>().text = Feedback.LeftText();
        Statistics.transform.GetChild(1).GetComponent<TMP_Text>().text = Feedback.MiddleText();
        Statistics.transform.GetChild(2).GetComponent<TMP_Text>().text = Feedback.RightText();
    }

    public void CloseUI()
    {
        //if (ControlGamepad.enabled && !ControlKeyboard.enabled)
        //{
        //    ControlGamepad.enabled = false;
        //    ControlKeyboard.enabled = true;
        //}
        //else if (!ControlGamepad.enabled && ControlKeyboard.enabled)
        //{
        //    ControlGamepad.enabled = false;
        //    ControlKeyboard.enabled = false;
        //    Time.timeScale = 1f;
        //}
        if (ControlGamepad.gameObject.activeSelf && !ControlKeyboard.gameObject.activeSelf)
        {
            ControlGamepad.gameObject.SetActive(false);
            ControlKeyboard.gameObject.SetActive(true);
        }
        else if (!ControlGamepad.gameObject.activeSelf && ControlKeyboard.gameObject.activeSelf)
        {
            ControlGamepad.gameObject.SetActive(false);
            ControlKeyboard.gameObject.SetActive(false);
            Time.timeScale = 1f;
        }
    }
}

public class Feedback
{
    public float PlayTime;
    public int EvadeCount;
    public int LightAttackCount;
    public float MorphCount;
    public float MorphProgress;
    public int PietaCount;
    public int HealCount;
    public int HittedCount;
    public int CollisionCount;

    public string LeftText()
    {
        return "挑戰時間\r\n" + (PlayTime / 60f).ToString("0") + "分 " + (PlayTime % 60f).ToString("0.00") + "秒" + "\r\n\r\n攻擊擊中次數\r\n" + LightAttackCount + "\r\n\r\n聖殤擊中次數\r\n" + PietaCount + "\r\n\r\n閃避次數\r\n" + EvadeCount;
    }
    public string MiddleText()
    {
        return "蛻變槽累積量\r\n" + MorphCount + "次滿條 " + (MorphProgress * 100).ToString("0.00") + "%累積量" + "\r\n\r\n治療次數\r\n" + HealCount + "\r\n\r\n被擊中次數\r\n" + HittedCount + "\r\n\r\n被碰撞傷害次數\r\n" + CollisionCount;
    }
    public string RightText()
    {
        return "";
    }
}