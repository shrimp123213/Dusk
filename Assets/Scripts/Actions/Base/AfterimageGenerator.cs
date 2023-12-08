// Assembly-CSharp, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null
// AfterimageGenerator
using DG.Tweening;
using UnityEngine;

public class AfterimageGenerator : MonoBehaviour
{
    public bool SelfDestory = true;

    [SerializeField]
    private float startDelay = float.MaxValue;
    [SerializeField]
    private float duration;

    private float emitLeft;

    public float EmitReset = .0125f;

    public float DelayFadeTime = .2f;
    public float FadeTime = .2f;
    public Color NewColor = new Color(1f, 1f, 1f, 0.5f);

    public float DelayMoveTime = 0f;
    public float MoveTime = 0f;
    public Vector3 MovePosition = Vector3.zero;

    public float DelayScaleTime = 0f;
    public float ScaleTime = 0f;
    public float ScaleMultiply = 1f;

    public Vector3 Offset = new Vector3(0f, 0f, 0.15f);

    public bool IsSprite;

    public bool UnscaleedTime;

    public Vector3 EulerAngles = Vector3.zero;

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
            duration -= Time.deltaTime;

            if (emitLeft <= 0f)
            {
                //Debug.Log("spawnEffect");
                
                if (IsSprite)
                {
                    GameObject obj = new GameObject();

                    obj.transform.eulerAngles = EulerAngles;

                    SpriteRenderer spriteRenderer = obj.AddComponent<SpriteRenderer>();
                    spriteRenderer.sprite = base.transform.GetChild(0).GetChild(0).GetComponent<SpriteRenderer>().sprite;

                    spriteRenderer.sortingLayerName = "Middle2";
                    spriteRenderer.sortingOrder = 9;

                    spriteRenderer.color = NewColor;
                    DOTween.Sequence().SetDelay(DelayFadeTime).Append(spriteRenderer.DOFade(0f, FadeTime)).SetUpdate(UnscaleedTime);

                    obj.transform.position = base.transform.position + Offset;
                    DOTween.Sequence().SetDelay(DelayMoveTime).Append(spriteRenderer.transform.DOMove(obj.transform.position + MovePosition, MoveTime)).SetUpdate(UnscaleedTime);

                    obj.transform.localScale = base.transform.GetChild(0).localScale;
                    DOTween.Sequence().SetDelay(DelayScaleTime).Append(spriteRenderer.transform.DOScale(obj.transform.localScale * ScaleMultiply, ScaleTime)).SetUpdate(UnscaleedTime);

                    Object.Destroy(obj, DelayFadeTime + DelayMoveTime + DelayScaleTime + FadeTime + MoveTime + ScaleTime);
                }
                
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
