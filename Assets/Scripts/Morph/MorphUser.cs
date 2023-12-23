using UnityEngine;

public class MorphUser : MonoBehaviour
{
    public static MorphUser Local;

    public float[] MorphProgressFactor;

    public float MorphProgress;

    public int MorphCount;

    public int MorphMax = 3;

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
        else if (MorphProgress > 0)
        {
            Consume(Mathf.Clamp(Time.deltaTime * 0.01f, 0, MorphProgress));
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
        MorphProgress += _progress / 100000 * MorphProgressFactor[MorphCount];
        if (MorphProgress >= 1f)
        {
            MorphCount = Mathf.Clamp(MorphCount + (int)Mathf.Floor(MorphProgress), 0, MorphMax);
            MorphProgress -= Mathf.Floor(MorphProgress);
            CheckSpin();
            AerutaDebug.i.Feedback.MorphCount++;
        }
        if (MorphCount >= MorphMax)
        {
            MorphProgress = 0f;
        }
        AerutaDebug.i.Feedback.MorphProgress = MorphProgress;

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

    public float GetMorphLevelDamageFactor()
    {
        float baseHitNeed = 1 / (MorphProgressFactor[0] * ActionLoader.i.Actions["Claw1"].MorphRecovery);
        
        float currentHitNeed = 1 / (MorphProgressFactor[MorphCount - 1] * ActionLoader.i.Actions["Claw1"].MorphRecovery);
        
        float hitNeedDiff = currentHitNeed - baseHitNeed;
        
        float progressNeedDiff = hitNeedDiff/ baseHitNeed;

        float multiply = 2f;
        return 1 + progressNeedDiff * multiply;
    }
}
