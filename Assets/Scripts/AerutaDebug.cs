using DG.Tweening;
using UnityEngine;
using UnityEngine.SceneManagement;
using UnityEngine.UI;
using TMPro;
using BehaviorDesigner.Runtime;
using TheKiwiCoder;

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
    public GameObject BlockEffect;
    public GameObject BloodEffect;
    public GameObject PenetrateTrail;

    public ParticleSystem Leaf;

    public Character Boss1;

    public Image ControlGamepad, ControlKeyboard;

    private void Awake()
    {
        i = this;

        if (ControlGamepad.enabled || ControlKeyboard.enabled)
            Time.timeScale = 0f;
    }

    public void CallEffect(int num)//顯示打中擊飛敵人、閃避成功等UI
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
        if (ControlGamepad.enabled && !ControlKeyboard.enabled)
        {
            ControlGamepad.enabled = false;
            ControlKeyboard.enabled = true;
        }
        else if (!ControlGamepad.enabled && ControlKeyboard.enabled)
        {
            ControlGamepad.enabled = false;
            ControlKeyboard.enabled = false;
            Time.timeScale = 1f;
        }
    }
}

public class Feedback
{
    public float PlayTime;
    public int MarkCount;
    public int MarkTriggerCount;
    public int BlockCount;
    public int UltimateCount;
    public int LightAttackCount;
    public int HeavyAttackCount;
    public int ChargeAttackCount;
    public float EnergyRecoveryCount;
    public int HealCount;
    public int HittedCount;

    public string LeftText()
    {
        return "挑戰時間：\r\n" + PlayTime + "\r\n\r\n標記次數：\r\n" + MarkCount + "\r\n\r\n觸發標記次數：\r\n" + MarkTriggerCount + "\r\n\r\n防禦次數：\r\n" + BlockCount;
    }
    public string MiddleText()
    {
        return "大招次數：\r\n" + UltimateCount + "\r\n\r\n輕攻擊次數：\r\n" + LightAttackCount + "\r\n\r\n重攻擊次數：\r\n" + HeavyAttackCount + "\r\n\r\n蓄力重攻擊次數：\r\n" + ChargeAttackCount;
    }
    public string RightText()
    {
        return "能量回復量：\r\n" + EnergyRecoveryCount + "\r\n\r\n治療次數：\r\n" + HealCount + "\r\n\r\n被擊中次數：\r\n" + HittedCount + "\r\n\r\n\r\n";
    }
}