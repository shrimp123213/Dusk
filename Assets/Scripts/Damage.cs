public class Damage
{ 
    public float Amount;

    public DamageType Type;

    public Damage(float _amount, DamageType _type)
    {
        Type = _type;
        Amount = _amount;
    }
}

public enum DamageType
{
    Claw,
    Burst,
    Gun,
    Heal,
}
