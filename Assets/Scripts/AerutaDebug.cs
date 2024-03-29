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
    //public GameObject BloodEffect;
    public GameObject PostBlurZoomIn;
    public GameObject PostBlurZoomInWeak;
    public GameObject PostBlurZoomOut;

    //public GameObject BlockFlashYellow;
    //public GameObject BlockFlashBlue;
    //public GameObject EvadeFinishCooldownEffect;
    public GameObject TransformationEffect;
    public GameObject PlayerAttackLandEffect;

    public ParticleSystem Leaf;

    public Character Boss1;

    public Image ControlGamepad, ControlKeyboard;

    public Contact contact;

    public Image FadeImage;
    public bool StartSceneFadeIn;
    public bool StartSceneFadeOut;

    private void Awake()
    {
        i = this;

        //if (ControlGamepad.enabled || ControlKeyboard.enabled)
        //    Time.timeScale = 0.001f;
        FadeImage.gameObject.SetActive(true);
        FadeImage.color = new Color(0, 0, 0, 1);
        
        StartSceneFadeIn = true;
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
        if (StartSceneFadeIn)
            SceneFadeIn();
        if (StartSceneFadeOut)
            SceneFadeOut();


        if (Input.GetKeyDown(KeyCode.Q))
        {
            RectTransform component = GameObject.Find("TimeDateIMG").GetComponent<RectTransform>();
            component.sizeDelta = ((component.sizeDelta.y == 500f) ? new Vector2(200f, 130f) : new Vector2(200f, 500f));
        }
        if (Input.GetKeyDown(KeyCode.F3))
        {
            PlayerMain.i.Morph.Add(100000f);
        }
        if (Input.GetKeyDown(KeyCode.F4))
        {
            Character component2 = Object.Instantiate(Resources.Load<GameObject>("Character/EnemyA/Enemy01"), PlayerMain.i.transform.position, Quaternion.identity).GetComponent<Character>();
            component2.Health = 100f;
            component2.Speed.BaseSet(0f);
        }

        if (Input.GetKeyDown(KeyCode.F5))
        {
            SceneManager.LoadScene("Main_menu");
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
        Statistics.transform.GetChild(1).GetComponent<TMP_Text>().text = Feedback.RightText();
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
        /*if (ControlGamepad.gameObject.activeSelf && !ControlKeyboard.gameObject.activeSelf)
        {
            //ControlGamepad.gameObject.SetActive(false);
            //ControlKeyboard.gameObject.SetActive(true);
        }
        else if (!ControlGamepad.gameObject.activeSelf && ControlKeyboard.gameObject.activeSelf)
        {
            //ControlGamepad.gameObject.SetActive(false);
            //ControlKeyboard.gameObject.SetActive(false);
            //Time.timeScale = 1f;
        }*/
    }

    private void SceneFadeIn()
    {
        FadeImage.color = new Color(0, 0, 0, FadeImage.color.a - 0.02f);
        if (FadeImage.color.a <= 0)
        {
            FadeImage.gameObject.SetActive(false);

            PlayerMain.i.CanInput = true;
            Camcam.i.FadeIn = false;

            StartSceneFadeIn = false;
        }
    }

    public void SceneFadeOut()
    {
        FadeImage.gameObject.SetActive(true);
        FadeImage.color = new Color(0, 0, 0, FadeImage.color.a + 0.02f);
        if (FadeImage.color.a >= 1)
        {
            SceneManager.LoadScene(SceneManager.GetActiveScene().buildIndex);
        }
    }

    public void SpawnPostBlurZoomIn(Vector3 center, bool isWeak)
    {
        //ChangePostBlurCenter
        ParticleSystemRenderer renderer = isWeak ? PostBlurZoomInWeak.GetComponent<ParticleSystemRenderer>() : PostBlurZoomIn.GetComponent<ParticleSystemRenderer>();
        Vector2 point = Camera.main.WorldToScreenPoint(center);
        point = new Vector2(point.x / Camera.main.pixelWidth, point.y / Camera.main.pixelHeight);
        renderer.sharedMaterial.SetFloat("_U", point.x);
        renderer.sharedMaterial.SetFloat("_V", point.y);

        Instantiate(isWeak ? PostBlurZoomInWeak : PostBlurZoomIn, center, Quaternion.identity, null);
    }
    public void SpawnPostBlurZoomOut(Vector3 center)
    {
        //ChangePostBlurCenter
        ParticleSystemRenderer renderer = PostBlurZoomOut.GetComponent<ParticleSystemRenderer>();
        Vector2 point = Camera.main.WorldToScreenPoint(center);
        point = new Vector2(point.x / Camera.main.pixelWidth, point.y / Camera.main.pixelHeight);
        renderer.sharedMaterial.SetFloat("_U", point.x);
        renderer.sharedMaterial.SetFloat("_V", point.y);

        Instantiate(PostBlurZoomOut, center, Quaternion.identity, null);
    }

}

public class Feedback
{
    public float PlayTime;

    public int HittedCount;

    public string LeftText()
    {
        return "挑戰時間\r\n" + (PlayTime / 60f).ToString("0") + "分 " + (PlayTime % 60f).ToString("0.00") + "秒";
    }
    public string RightText()
    {
        return "被擊中次數\r\n" + HittedCount;
    }
}