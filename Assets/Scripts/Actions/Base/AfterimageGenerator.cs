// Assembly-CSharp, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null
// AfterimageGenerator
using DG.Tweening;
using UnityEngine;

public class AfterimageGenerator : MonoBehaviour
{
    public bool SelfDestory = true;

    private float startDelay = float.MaxValue;

    private float duration;

    private float emitLeft;

    public float EmitReset = .025f;

    public float DelayFadeTime = .2f;
    public float FadeTime = .2f;
    public Color NewColor = new Color(1f, 1f, 1f, 0.35f);

    public float DelayMoveTime = 0f;
    public float MoveTime = 0f;
    public Vector3 MovePosition = Vector3.zero;

    public float DelayScaleTime = 0f;
    public float ScaleTime = 0f;
    public float ScaleMultiply = 1f;

    public Vector3 Offset = new Vector3(0f, 0f, 0.15f);


    private void Awake()
    {
        
    }

    private void Update()
    {
        if (startDelay > 0)
        {
            startDelay -= Time.deltaTime;
        }
        else
        {
            if (emitLeft <= 0f)
            {
                //Debug.Log("spawnEffect");
                GameObject obj = new GameObject();
                SpriteRenderer spriteRenderer = obj.AddComponent<SpriteRenderer>();
                spriteRenderer.sprite = base.transform.GetChild(0).GetComponent<SpriteRenderer>().sprite;

                spriteRenderer.sortingLayerName = "Middle";
                spriteRenderer.sortingOrder = 1;

                spriteRenderer.color = NewColor;
                DOTween.Sequence().SetDelay(DelayFadeTime).Append(spriteRenderer.DOFade(0f, FadeTime));

                obj.transform.position = base.transform.position + Offset;
                DOTween.Sequence().SetDelay(DelayMoveTime).Append(spriteRenderer.transform.DOMove(obj.transform.position + MovePosition, MoveTime));

                obj.transform.localScale = base.transform.GetChild(0).localScale;
                DOTween.Sequence().SetDelay(DelayScaleTime).Append(spriteRenderer.transform.DOScale(obj.transform.localScale * ScaleMultiply, ScaleTime));

                Object.Destroy(obj, DelayFadeTime + DelayMoveTime + DelayScaleTime + FadeTime + MoveTime + ScaleTime);
                emitLeft = EmitReset;
            }
            emitLeft -= Time.deltaTime;
        }
    }

    public void SetLifeTime(float _StartDelay,float _Duration)
    {
        startDelay = _StartDelay;
        duration = _Duration;

        if (SelfDestory)
        {
            Object.Destroy(this, startDelay + duration);
        }
    }
}
