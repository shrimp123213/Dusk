using DG.Tweening;
using Spine.Unity;
using UnityEngine;

public class InvincibleState : MonoBehaviour
{
    public float InvincibleTime;

    public float InvincibleTimeMax;

    public float Interval;
    public float IntervalMax;

    public SkeletonMecanim Renderer;

    [SerializeField]
    private Material material;

    private void Start()
    {
        Renderer.skeleton.SetColor(Color.white);
    }

    private void Update()
    {
        if (Interval > 0)
            Interval -= Time.deltaTime;
        if (InvincibleTime > 0)
            InvincibleTime -= Time.deltaTime;

        if (Interval <= 0f && InvincibleTime > 0)
        {
            Interval = IntervalMax;

            if (Renderer.skeleton.GetColor() == Color.white) 
            {
                material.DOComplete();
                material.DOColor(new Color(.3f, .3f, .3f, 1f), IntervalMax);
            }
            else
            {
                material.DOComplete();
                material.DOColor(Color.white, IntervalMax);
            }
        }

        if (InvincibleTime <= 0)
            Renderer.skeleton.SetColor(Color.white);
        else
            Renderer.skeleton.SetColor(material.color);
    }

    public void Invincible()
    {
        InvincibleTime = InvincibleTimeMax;
        Interval = 0;
    }
}
