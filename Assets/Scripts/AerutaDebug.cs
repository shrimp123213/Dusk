using System.Collections;
using System.Collections.Generic;
using DG.Tweening;
using UnityEngine;
using UnityEngine.SceneManagement;
using UnityEngine.UI;
using TMPro;
using BehaviorDesigner.Runtime;
using UnityEngine.EventSystems;
using UnityEngine.InputSystem;
using UnityEngine.InputSystem.UI;


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
    public GameObject PostBlurZoomOutBoss0;
    public bool forBoss0;

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
    
    [Header("玩家死亡介面")]
    public GameObject failCanvas;
    
    private ParticleSystem failEffect;
    private bool failCanvasActive = false;
    private Image failFadeImage;
    
    [Header("暫停介面")]
    public GameObject pauseCanvas;
    public bool isPause = false;
    
    [Header("玩家檢查點")]
    public bool hasCheckPoint = false;
    public Transform checkPointPos;
    

    /*public bool SetMenuStatus(bool open)
    {
        isPause = open;
        Time.timeScale = open ? 0 : 1;
        return open;
    }*/

    private void Awake()
    {
        i = this;

        //if (ControlGamepad.enabled || ControlKeyboard.enabled)
        //    Time.timeScale = 0.001f;
        FadeImage.gameObject.SetActive(true);
        FadeImage.color = new Color(0, 0, 0, 1);
        
        StartSceneFadeIn = true;
        if (failCanvas != null)
        {
            failCanvas.SetActive(false);
            failEffect = failCanvas.GetComponentInChildren<ParticleSystem>();
            failCanvasActive = false;
            failFadeImage = failCanvas.transform.GetChild(4).GetComponent<Image>();
        }
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
        /*if(hasCheckPoint && Respawn.i.player != null)
            ReSpawnPlayer();*/


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
            if(!PlayerMain.i.isDead)
                PlayerMain.i.ResetPlayerHealth();
            
            //Character component2 = Object.Instantiate(Resources.Load<GameObject>("Character/EnemyA/Enemy01"), PlayerMain.i.transform.position, Quaternion.identity).GetComponent<Character>();
            //component2.Health = 100f;
            //component2.Speed.BaseSet(0f);
        }

        if (Input.GetKeyDown(KeyCode.F5))
        {
            SceneManager.LoadScene("Main_menu");
        }
        
        if (Input.GetKeyDown(KeyCode.F6))
        {
            SceneManager.LoadScene(1);
            Respawn.i.respawnPoints.Clear();
        }
        
        if (Input.GetKeyDown(KeyCode.F7))
        {
            SceneManager.LoadScene(2);
        }
        
        if (Input.GetKeyDown(KeyCode.F8))
        {
            SceneManager.LoadScene(3);
            DramaManager.i.dramaCatEnd = true;
        }
        if (Input.GetKeyDown(KeyCode.F9))
        {
            if(checkPointPos == null)
                return;
            PlayerMain.i.transform.position = checkPointPos.position;
            DramaManager.i.dramaCatEnd = true;
        }
        if(Input.GetKeyDown(KeyCode.F10))
            PlayerMain.i.Health = 1;
        

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
        if (Input.GetKeyDown(KeyCode.F2))
        {
            Boss1.Health = 1;
        }
        //Debug.Log("isPause:"+isPause);
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

        if (PostBlurZoomOutBoss0 != null && forBoss0)
        {
            Instantiate(PostBlurZoomOutBoss0, center, Quaternion.identity, null);
            forBoss0 = false;
        }
        else
            Instantiate(PostBlurZoomOut, center, Quaternion.identity, null);
        //Instantiate(PostBlurZoomOut, center, Quaternion.identity, null);
    }
    
    public void ShowFailCanvas()
    {
        if(failCanvasActive)
            return;
        failCanvas.SetActive(true);
        failEffect.Play();
        failCanvasActive = true;
        failFadeImage.DOFade(1, 2f).SetDelay(2f).OnComplete(() => {
            if (failFadeImage.color.a >= 1)
            {
                SceneManager.LoadScene(SceneManager.GetActiveScene().buildIndex);
                Debug.Log("Restart");
            }
        });
    }
    
    public void SetPauseStatus(bool pause)
    {
        if (pause)
        {
            if (isPause) return;
            pauseCanvas.SetActive(true);
            isPause = true;
            Time.timeScale = 0;
            PlayerMain.i.playerAct.Disable();
        }
        else
        {
            if (!isPause) return;
            pauseCanvas.SetActive(false);
            isPause = false;
            Time.timeScale = 1;
            PlayerMain.i.playerAct.Enable();
        }
    }

    public void ReSpawnPlayer()
    {
        Respawn.i.RespawnPlayer();
        hasCheckPoint = false;
    }
    
    public void GamepadVibrate(float low, float high, float time) => StartCoroutine(IEGamepadVibrate(low, high, time));
 
    public IEnumerator IEGamepadVibrate(float low, float high, float time)
    {
        //防止因未连接手柄造成的 DebugError
        if (Gamepad.current == null)
            yield break;
 
        //设置手柄的 震动速度 以及 恢复震动 , 计时到达之后暂停震动
        Gamepad.current.SetMotorSpeeds(low, high);
        Gamepad.current.ResumeHaptics();
        var endTime = Time.unscaledTime + time;
 
        while (Time.unscaledTime < endTime)
        {
            Gamepad.current.ResumeHaptics();
            yield return null;
        }
 
        if (Gamepad.current == null)
            yield break;
 
        Gamepad.current.PauseHaptics();
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