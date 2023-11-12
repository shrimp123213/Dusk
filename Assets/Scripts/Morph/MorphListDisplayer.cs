using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class MorphListDisplayer : MonoBehaviour
{
    public static MorphListDisplayer i;

    public MorphUser Target;

    public Transform TransList;

    public MorphInUI[] MorphUI;

    public CanvasGroup CanvasGroup;

    public Sprite[] MarkSprites;
    public Image MarkLevelImage;
    public SpriteRenderer MarkLevelImagePlayer;

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

        MarkLevelImage.sprite = MarkSprites[Target.MorphCount];
        MarkLevelImagePlayer.sprite = MarkSprites[Target.MorphCount];
    }
}
