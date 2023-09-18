using DG.Tweening;
using TMPro;
using UnityEngine;

public class SkillPopup : MonoBehaviour
{
    public static SkillPopup i;

    public TextMeshProUGUI SkillText;

    public Sequence CurrentSequence;

    private void Awake()
    {
        i = this;
        SkillText = base.transform.GetChild(0).GetComponent<TextMeshProUGUI>();
    }

    public void ShowMessage(string _content)
    {
        SkillText.text = _content;
        if (CurrentSequence != null && CurrentSequence.active)
        {
            CurrentSequence.Kill();
        }
        base.transform.localScale = Vector3.zero;
        CurrentSequence = DOTween.Sequence();
        CurrentSequence.SetUpdate(isIndependentUpdate: true).SetEase(Ease.OutBack);
        CurrentSequence.Append(base.transform.DOScale(1f, 0.15f)).SetEase(Ease.Linear).AppendInterval(1.25f)
            .Append(base.transform.DOScale(0f, 0.25f));
    }
}
