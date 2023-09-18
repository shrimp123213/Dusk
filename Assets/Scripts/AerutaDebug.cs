using DG.Tweening;
using UnityEngine;

public class AerutaDebug : MonoBehaviour
{
    public static AerutaDebug i;

    public RectTransform[] rectTransforms;

    public Sequence[] Sequences = new Sequence[4];

    public GameObject PrefabClap;

    private void Awake()
    {
        i = this;
    }

    public void CallEffect(int num)
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
        if (Input.GetKeyDown(KeyCode.Q))
        {
            RectTransform component = GameObject.Find("TimeDateIMG").GetComponent<RectTransform>();
            component.sizeDelta = ((component.sizeDelta.y == 500f) ? new Vector2(200f, 130f) : new Vector2(200f, 500f));
        }
        if (Input.GetKeyDown(KeyCode.F3))
        {
            PlayerMain.i.Orb.Add(10f);
        }
        if (Input.GetKeyDown(KeyCode.F4))
        {
            Character component2 = Object.Instantiate(Resources.Load<GameObject>("Character/EnemyA/Enemy01"), PlayerMain.i.transform.position, Quaternion.identity).GetComponent<Mob>();
            component2.Health = 100f;
            component2.Speed.BaseSet(0f);
        }
    }

    public void InsClap(Vector3 _v3)
    {
        Object.Destroy(Object.Instantiate(PrefabClap, _v3, Quaternion.identity), 1.5f);
    }
}
