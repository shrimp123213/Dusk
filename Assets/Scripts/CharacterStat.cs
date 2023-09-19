using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CharacterStat
{
    private float _Base;

    private float _Final;

    private bool Dirty;

    private List<float> Plains = new List<float>();

    private List<float> Multipliers = new List<float>();

    public float Base
    {
        get
        {
            CheckDirty();
            return _Base;
        }
    }

    public float Final
    {
        get
        {
            CheckDirty();
            return _Final;
        }
    }

    public void CheckDirty()
    {
        if (Dirty)
        {
            Dirty = false;
            CacuFinal();
        }
    }

    public void BaseSet(float NewB)
    {
        _Base = NewB;
        Dirty = true;
    }

    public void BaseMultiply(float mul)
    {
        _Base *= mul;
        Dirty = true;
    }

    public void BaseAdd(float Num)
    {
        _Base += Num;
        Dirty = true;
    }

    public CharacterStat(float baseNum)
    {
        _Base = baseNum;
        Dirty = true;
    }

    public void MultiplierAdd(float Num, bool Revert = false)
    {
        if (Revert)
        {
            if (Multipliers.Contains(Num))
            {
                Multipliers.Remove(Num);
            }
        }
        else
        {
            Multipliers.Add(Num);
        }
        Dirty = true;
    }

    public void PlainAdd(float Num, bool Revert = false)
    {
        if (Revert)
        {
            if (Plains.Contains(Num))
            {
                Plains.Remove(Num);
            }
        }
        else
        {
            Plains.Add(Num);
        }
        Dirty = true;
    }

    public void CacuFinal()
    {
        float num = 1f;
        float num2 = 0f;
        foreach (float multiplier in Multipliers)
        {
            num *= 1f + multiplier;
        }
        foreach (float plain in Plains)
        {
            num2 += plain;
        }
        _Final = Mathf.Clamp(Base * num + num2, 0f, 3000000f);
    }
}
