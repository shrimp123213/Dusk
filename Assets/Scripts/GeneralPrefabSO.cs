using UnityEngine;

[CreateAssetMenu]
public class GeneralPrefabSO : ScriptableObject
{
    protected static GeneralPrefabSO instance;

    public GameObject P_HealthShard;

    public static GeneralPrefabSO i
    {
        get
        {
            if (instance == null)
            {
                instance = Resources.Load<GeneralPrefabSO>("Prefabs");
            }
            return instance;
        }
    }
}
