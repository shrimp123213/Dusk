using System;
using System.Collections;
using System.Collections.Generic;
using Spine.Unity;
using UnityEngine;
using DG.Tweening;
using UnityEngine.UI;

public class DeadBody : MonoBehaviour
{
    public Transform deadBody;
    public PlayerMain playerMain;
    public SkeletonMecanim deadBodyRender;
    
    public Image reviveSlider;
    
    public float reviveTime = 3f;
    [SerializeField]
    private float reviveTimer = 0f;
    
    private Animator deadBodyAnimator;
    
    private bool isReviving;
    
    public RectTransform reviveCanvas;

    private void Awake()
    {
        playerMain = PlayerMain.i;
        deadBody = gameObject.transform.GetChild(0);
        deadBodyRender = deadBody.GetComponent<SkeletonMecanim>();
        deadBodyAnimator = deadBody.GetComponent<Animator>();
    }
    
    void Start()
    {
        reviveSlider.fillAmount = 0;
        isReviving = false;
    }
    
    void Update()
    {
        reviveSlider.fillAmount = reviveTimer / reviveTime;
        /*
        // 將物件的世界座標轉換為螢幕座標
        Vector2 screenPosition = Camera.main.WorldToScreenPoint(transform.position);

        // 將螢幕座標轉換為Canvas座標
        Vector2 canvasPosition;
        RectTransformUtility.ScreenPointToLocalPointInRectangle(reviveCanvas.parent as RectTransform, screenPosition, Camera.main, out canvasPosition);

        // 將reviveCanvas的位置設定為物件的上方
        reviveCanvas.localPosition = canvasPosition + new Vector2(0, 1.5f); //物件與reviveCanvas之間的距離
        */
        if (!isReviving && reviveTimer >= reviveTime)
        {
            isReviving = true;
            playerMain.Revive();
            reviveCanvas.gameObject.SetActive(false);
            DOVirtual.Color(deadBodyRender.skeleton.GetColor(), new Color(1f, 1f, 1f, 0), 1f, (value) =>
            {
                deadBodyRender.skeleton.SetColor(value);
                Destroy(gameObject,1);
            });
            reviveTimer = 0;
        }
    }
    
    public void SetFace(Character _m)
    {
        deadBody.localScale = new Vector3(_m.Facing, 1, 1);
        DOVirtual.Color(deadBodyRender.skeleton.GetColor(), new Color(.3f, .3f, .3f, 1), 1f, (value) =>
        {
            deadBodyRender.skeleton.SetColor(value);
        });
        deadBodyAnimator.Play("Failed", 0, 1);
    }

    private void OnTriggerStay2D(Collider2D other)
    {
        if (!isReviving && other.CompareTag("Player") && !playerMain.isDead)
        {
            reviveTimer += Time.deltaTime;
            reviveTimer = Mathf.Clamp(reviveTimer, 0, reviveTime);
            Debug.Log("Revive Timer: " + reviveTimer);
        }
        
    }
    
    private void OnTriggerExit2D(Collider2D other)
    {
        if (!isReviving)
        {
            //reviveTimer -= Time.deltaTime;
            //reviveTimer = Mathf.Clamp(reviveTimer, 0, reviveTime);
        }
    }
}
