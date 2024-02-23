
using UnityEngine;
using UnityEngine.UI;

public class MorphInUI : MonoBehaviour
{
    public float TargetAmount;

    public float Amount;

    private Image ImgBack;

    private Image ImgFront;

    private Image ImgBall;
    private Image ImgBallMask;

    private bool Setted;

    private void Awake()
    {
        //ImgBack = GetComponent<Image>();
        //ImgFront = base.transform.GetChild(0).GetComponent<Image>();

        ImgFront = transform.GetChild(0).GetComponent<Image>();
        ImgBall = GetComponent<Image>();
        //ImgBallMask = transform.GetChild(0).GetComponent<Image>();
    }

    public void SetFill(float amoumt, bool isDrive = false)
    {
        TargetAmount = amoumt;
        if (amoumt == 0f)
        {
            if (!Setted)
            {
                Setted = true;
                //ImgBack.color = Color.clear;
                //ImgBack.color = new Color(0.125f, 0.125f, .85f, 0.5f);
                //ImgFront.color = Color.clear;
                ImgFront.fillAmount = 0f;
                ImgBall.fillAmount = 0f;
                //ImgBallMask.fillAmount = 0f;
                Amount = 0f;
                TargetAmount = 0f;
            }
        }
        else
        {
            Setted = false;
            Amount = Mathf.Lerp(Amount, TargetAmount, Time.deltaTime * 15f);
            ImgFront.fillAmount = Mathf.Lerp(.165f, 0.95f, Amount) / 0.95f;
            ImgBall.fillAmount = Amount;
            //ImgBallMask.fillAmount = Amount;
            if (!isDrive)
            {
                //ImgBack.color = new Color(0.125f, 0.125f, .85f, 0.5f + Amount * 0.5f);
                //ImgFront.color = new Color(1f, 1f, 1f, 0.25f + Amount * 0.75f);
            }
            else
            {
                //ImgBack.color = new Color(0.5f, 0.2f, 0.2f, 0.5f + Amount * 0.5f);
                //ImgFront.color = new Color(1f, 0.297f, 0.297f, 0.25f + Amount * 0.75f);
            }
        }
    }
}
