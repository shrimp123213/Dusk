using DG.Tweening;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using static FunkyCode.DayLightCollider2D;

public class MorphListDisplayer : MonoBehaviour
{
    public static MorphListDisplayer i;

    public MorphUser Target;

    public Transform TransList;

    public MorphInUI[] MorphUI;

    public CanvasGroup CanvasGroup;

    public Sprite[] MarkSprites;
    public Image MarkLevelImage;

    public float Interval;
    public float IntervalMax;


    private void Awake()
    {
        MorphListDisplayer.i = this;
        CanvasGroup = GetComponent<CanvasGroup>();
        
    }

    private void Update()
    {
        //for (int i = 0; i < MorphUI.Length; i++) 
        //{
        //    if (Target.MorphMax <= i || Target.MorphCount < i)
        //    {
        //        MorphUI[i].SetFill(0f);
        //    }
        //    else if (Target.MorphCount > i)
        //    {
        //        MorphUI[i].SetFill(1f, Target.Drive);
        //    }
        //    else
        //    {
        //        MorphUI[i].SetFill(Target.MorphProgress, Target.Drive);
        //    }
        //}
        if (Target.MorphCount == Target.MorphMax)
            MorphUI[0].SetFill(1f, Target.Drive);
        else
            MorphUI[0].SetFill(Target.MorphProgress, Target.Drive);

        //if (!PlayerMain.i.CatMode)
        if(PlayerMain.i.state != PlayerMain.State.Cat)
        {
            if (MarkLevelImage.color != Color.white)
            {
                MarkLevelImage.DOComplete();
                MarkLevelImage.color = Color.white;
            }
            MarkLevelImage.sprite = MarkSprites[Target.MorphCount];
        }
        else
        {
            MarkLevelImage.sprite = MarkSprites[1];

            if (Interval > 0)
                Interval -= Time.deltaTime;

            if (Interval <= 0f)
            {
                Interval = Mathf.Clamp(Target.TotalMorph, .05f, 1f);

                if (MarkLevelImage.color == Color.white)
                {
                    MarkLevelImage.DOComplete();
                    MarkLevelImage.DOColor(new Color(.3f, .3f, .3f, 1f), Target.TotalMorph);
                }
                else
                {
                    MarkLevelImage.DOComplete();
                    MarkLevelImage.DOColor(Color.white, Target.TotalMorph);
                }
            }
        }
            
    }
}
