using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class MorphListDisplayer : MonoBehaviour
{
    public static MorphListDisplayer i;

    public MorphUser Target;

    public Transform TransList;

    public MorphInUI MorphUI;

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
        if (Target.MorphCount == 3) 
            MorphUI.SetFill(1f, Target.Drive);
        else
            MorphUI.SetFill(Target.MorphProgress, Target.Drive);

        MarkLevelImage.sprite = MarkSprites[Target.MorphCount];
        MarkLevelImagePlayer.sprite = MarkSprites[Target.MorphCount];
    }
}
