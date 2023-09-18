using UnityEngine;

public class OrbSpinner : MonoBehaviour
{
    public static OrbSpinner i;

    public GameObject PrefabOrb;

    public int CurrentCount;

    public Transform FacingSprite;

    public Vector3[] TargetPos;

    private void Awake()
    {
        i = this;
        FacingSprite = base.transform.parent.GetChild(0);
    }

    private void Update()
    {
        int num = (int)FacingSprite.localScale.x;
        base.transform.localEulerAngles = new Vector3(57.5f, num * 55, base.transform.localEulerAngles.z);
        for (int i = 0; i < base.transform.childCount; i++)
        {
            Transform child = base.transform.GetChild(i);
            child.LookAt(CameraManager.Main.transform, Vector3.up);
            child.localPosition = Vector3.Lerp(base.transform.GetChild(i).localPosition, TargetPos[i], 2.5f * Time.deltaTime);
            float num2 = Mathf.Lerp(0.5f, 1f, (0f - child.position.z + 0.9f) / 1.8f);
            child.localScale = new Vector3(num2, num2, 1f);
        }
        float num3 = 40 + base.transform.childCount * 10;
        base.transform.Rotate(new Vector3(0f, 0f, num3 * Time.deltaTime * (float)num));
    }

    public void SetOrb(int _count)
    {
        CurrentCount = _count;
        TargetPos = GetPolygonPoints(_count);
        if (base.transform.childCount < TargetPos.Length)
        {
            for (int i = 0; i < TargetPos.Length - base.transform.childCount; i++)
            {
                Object.Instantiate(PrefabOrb, base.transform).transform.localPosition = Vector3.zero;
            }
        }
        else if (base.transform.childCount > TargetPos.Length)
        {
            for (int num = base.transform.childCount - 1; num >= TargetPos.Length; num--)
            {
                base.transform.GetChild(num).GetComponent<KineticOrb>().StartAction();
                base.transform.GetChild(num).SetParent(null);
            }
        }
    }

    public Vector3[] GetPolygonPoints(int _gons)
    {
        Vector3[] array = new Vector3[_gons];
        for (int i = 0; i < _gons; i++)
        {
            array[i] = Quaternion.AngleAxis(360 / _gons * i, Vector3.forward) * new Vector3(0f, 0.9f, 0f);
            Debug.Log(array[i]);
        }
        return array;
    }
}
