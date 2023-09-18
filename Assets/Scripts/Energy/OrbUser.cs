using UnityEngine;

public class OrbUser : MonoBehaviour
{
    public static OrbUser Local;

    public float OrbProgress;

    public int OrbCount;

    public int OrbMax = 3;

    public bool Drive;

    public float TotalOrb => (float)OrbCount + OrbProgress;

    private void Update()
    {
        if (OrbCount < OrbMax)
        {
            Add(Time.deltaTime * 0.05f);
        }
    }

    public void Consume(float _count = 1f)
    {
        float num = (float)OrbCount + OrbProgress - _count;
        OrbCount = Mathf.Clamp((int)num, 0, OrbMax);
        OrbProgress = num % 1f;
        CheckSpin();
    }

    public void Add(float _progress)
    {
        OrbProgress += _progress;
        if (OrbProgress >= 1f)
        {
            OrbCount = Mathf.Clamp(OrbCount + (int)Mathf.Floor(OrbProgress), 0, OrbMax);
            OrbProgress -= Mathf.Floor(OrbProgress);
            CheckSpin();
        }
        if (OrbCount >= OrbMax)
        {
            OrbProgress = 0f;
        }
    }

    public void Set(int _count, float _progress)
    {
        OrbProgress = _progress;
        OrbCount = _count;
        CheckSpin();
    }

    public void CheckSpin()
    {
        if (OrbSpinner.i.CurrentCount != OrbCount)
        {
            OrbSpinner.i.SetOrb(OrbCount);
        }
    }
}
