using UnityEngine;

public class MorphUser : MonoBehaviour
{
    public static MorphUser Local;

    public float MorphProgress;

    public int MorphCount;

    public int MorphMax = 5;

    public bool Drive;

    public float TotalMorph => (float)MorphCount + MorphProgress;

    public float MorphDecreaseDelayTimeMax;
    public float DelayTime;

    private void Update()
    {
        if (MorphCount < MorphMax)
        {
            //Add(Time.deltaTime * 0.1f);
        }

        if (DelayTime > 0)
        {
            DelayTime -= Time.deltaTime;
        }
        else if (TotalMorph > 0)
        {
            Consume(Time.deltaTime * 0.01f);
        }
    }

    public void Consume(float _count = 1f, bool _delay = false)
    {
        float num = (float)MorphCount + MorphProgress - _count;
        MorphCount = Mathf.Clamp((int)num, 0, MorphMax);
        MorphProgress = num % 1f;
        CheckSpin();

        if (_delay)
            DelayTime = MorphDecreaseDelayTimeMax;
    }

    public void Add(float _progress)
    {
        MorphProgress += _progress;
        if (MorphProgress >= 1f)
        {
            MorphCount = Mathf.Clamp(MorphCount + (int)Mathf.Floor(MorphProgress), 0, MorphMax);
            MorphProgress -= Mathf.Floor(MorphProgress);
            CheckSpin();
        }
        if (MorphCount >= MorphMax)
        {
            MorphProgress = 0f;
        }

        DelayTime = MorphDecreaseDelayTimeMax;
    }

    public void Set(int _count, float _progress)
    {
        MorphProgress = _progress;
        MorphCount = _count;
        CheckSpin();
    }

    public void CheckSpin()
    {
        //if (MorphSpinner.i.CurrentCount != MorphCount)
        //{
        //    MorphSpinner.i.SetMorph(MorphCount);
        //}
    }
}
