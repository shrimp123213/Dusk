// Assembly-CSharp, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null
// AfterimageGenerator
using DG.Tweening;
using UnityEngine;

public class AfterimageGenerator : MonoBehaviour
{
    public bool SelfDestory = true;

    public float StartDelay = float.MaxValue;

    public float Duration;

    public float EmitLeft;

    private void Awake()
    {
        
    }

    private void Update()
    {
        if (StartDelay > 0)
        {
            StartDelay -= Time.deltaTime;
        }
        else
        {
            if (EmitLeft <= 0f)
            {
                GameObject obj = new GameObject();
                SpriteRenderer spriteRenderer = obj.AddComponent<SpriteRenderer>();
                spriteRenderer.sprite = base.transform.GetChild(0).GetComponent<SpriteRenderer>().sprite;
                spriteRenderer.color = new Color(1f, 1f, 1f, 0.35f);
                DOTween.Sequence().SetDelay(.2f).Append(spriteRenderer.DOFade(0f, 0.2f));
                obj.transform.position = base.transform.position + new Vector3(0f, 0f, 0.15f);
                obj.transform.localScale = base.transform.GetChild(0).localScale;
                Object.Destroy(obj, 1f);
                EmitLeft = 0.02f;
            }
            EmitLeft -= Time.deltaTime;
        }
    }

    public void SetValue(float _StartDelay,float _Duration)
    {
        StartDelay = _StartDelay;
        Duration = _Duration;

        if (SelfDestory)
        {
            Object.Destroy(this, Duration);
        }
    }
}
