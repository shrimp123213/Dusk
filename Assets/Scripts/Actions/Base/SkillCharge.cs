using TMPro;
using UnityEngine;
using UnityEngine.UI;

public class SkillCharge : MonoBehaviour
{
    public static SkillCharge i;

    public Color NormalColor;

    public Color SuccessColor;

    private CanvasGroup CanvasGroup;

    private Image FillImage;

    private TextMeshProUGUI DisText;

    private RectTransform SuccessRange;

    private RectTransform FillRange;

    private float SuccessMin;

    private float SuccessMax;

    private void Awake()
    {
        i = this;
        CanvasGroup = GetComponent<CanvasGroup>();
        FillImage = base.transform.GetChild(0).GetComponent<Image>();
        DisText = base.transform.GetChild(1).GetComponent<TextMeshProUGUI>();
        SuccessRange = base.transform.GetChild(0).GetChild(0).GetComponent<RectTransform>();
        FillRange = base.transform.GetChild(0).GetComponent<RectTransform>();
    }

    public void SetText(string _content)
    {
        DisText.text = _content;
    }

    public void SetSuccessTime(float _rate)
    {
        if (_rate > 0f)
        {
            SuccessMin = _rate;
            SuccessMax = 1f;
            float x = FillRange.rect.width * SuccessMin;
            float num = FillRange.rect.width * (1f - SuccessMax);
            SuccessRange.offsetMin = new Vector2(x, SuccessRange.offsetMin.y);
            SuccessRange.offsetMax = new Vector2(0f - num, SuccessRange.offsetMax.y);
        }
        else
        {
            SuccessMin = 0f;
            SuccessMax = 0f;
        }
    }

    public void SetAmount(float _am)
    {
        FillImage.fillAmount = _am;
        CanvasGroup.alpha = ((_am != 0f) ? 1 : 0);
        if (FillImage.fillAmount > SuccessMin && FillImage.fillAmount <= SuccessMax)
        {
            FillImage.color = SuccessColor;
        }
        else
        {
            FillImage.color = NormalColor;
        }
    }
}
