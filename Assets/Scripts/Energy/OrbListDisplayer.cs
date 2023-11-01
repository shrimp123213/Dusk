using System.Collections.Generic;
using UnityEngine;

public class OrbListDisplayer : MonoBehaviour
{
    public static OrbListDisplayer i;

    public GameObject PrefabOrb;

    public OrbUser Target;

    public Transform TransList;

    public List<OrbInUI> Orbs;

    public CanvasGroup CanvasGroup;

    private void Awake()
    {
        OrbListDisplayer.i = this;
        CanvasGroup = GetComponent<CanvasGroup>();
        for (int i = 0; i < Target.OrbMax; i++)
        {
            Orbs.Add(Object.Instantiate(PrefabOrb, TransList).GetComponent<OrbInUI>());
            Orbs[i].transform.SetAsLastSibling();
            Orbs[i].GetComponent<RectTransform>().localPosition = new Vector3(i * PrefabOrb.GetComponent<RectTransform>().rect.width, 0, 0);
        }
    }

    private void Update()
    {
        for (int i = 0; i < Orbs.Count; i++)
        {
            if (Target.OrbMax <= i || Target.OrbCount < i)
            {
                Orbs[i].SetFill(0f);
            }
            else if (Target.OrbCount > i)
            {
                Orbs[i].SetFill(1f, Target.Drive);
            }
            else
            {
                Orbs[i].SetFill(Target.OrbProgress, Target.Drive);
            }
        }
    }
}
