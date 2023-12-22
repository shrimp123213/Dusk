using FunkyCode.SuperTilemapEditorSupport.Light.Shadow;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using Unity.VisualScripting;
using UnityEngine;
using UnityEngine.TextCore.Text;
using UnityEngine.UI;
using UnityEngine.UIElements.Experimental;
using static Pieta;

public class Pieta : MonoBehaviour
{
    
    private List<PietaTarget> PietaTargets;

    public GameObject HintPrefab;
    public Sprite[] HintSprites;

    public static Pieta i;

    [SerializeField]
    private float farDis, nearDis;

    private PlayerMain Player;

    public List<PietaTarget> CanPietaList;
    public Vector2 PietaEndDis;

    public Collider2D FarestTargetCollider2D;

    private void Awake()
    {
        i = this;
        Player = GetComponent<PlayerMain>();
        PietaTargets = new List<PietaTarget>();
        CanPietaList = new List<PietaTarget>();
        PietaEndDis = Vector2.zero;
        FarestTargetCollider2D = null;
    }

    private void Update()
    {
        MarkNearbyEnemys();
    }

    public RaycastHit2D[] CanPietaRange(float _dis)
    {
        BoxCollider2D component = Player.GetComponent<BoxCollider2D>();
        RaycastHit2D[] raycastHit2D = Physics2D.BoxCastAll(component.bounds.center, component.size, 0f, Vector2.right * Player.Facing, _dis, LayerMask.GetMask("HurtBox"));

        return raycastHit2D;
    }

    public SpriteRenderer Appear(Transform target, GameObject HintPrefab)
    {
        return Instantiate(HintPrefab, target.position + (Vector3)target.transform.parent.GetComponent<Character>().PietaPos, Quaternion.identity, target).GetComponent<SpriteRenderer>();
    }

    public void Disappear(PietaTarget pietaTarget)
    {
        PietaTargets.Remove(pietaTarget);
        Destroy(pietaTarget.Hint.gameObject);
    }

    public void MarkNearbyEnemys()
    {
        Vector2 Range = Vector2.one* farDis;

        Vector3 topRight = Range / 2;
        Vector3 topLeft = new Vector2(-Range.x, Range.y) / 2;
        Vector3 bottomRight = new Vector2(Range.x, -Range.y) / 2;
        Vector3 bottomLeft = -Range / 2;

        Debug.DrawLine(Player.transform.position + topRight, Player.transform.position + topLeft, Color.magenta);
        Debug.DrawLine(Player.transform.position + topRight, Player.transform.position + bottomRight, Color.magenta);
        Debug.DrawLine(Player.transform.position + topLeft, Player.transform.position + bottomLeft, Color.magenta);
        Debug.DrawLine(Player.transform.position + bottomRight, Player.transform.position + bottomLeft, Color.magenta);

        Vector2 Range2 = Vector2.one * nearDis;

        Vector3 topRight2 = Range2 / 2;
        Vector3 topLeft2 = new Vector2(-Range2.x, Range2.y) / 2;
        Vector3 bottomRight2 = new Vector2(Range2.x, -Range2.y) / 2;
        Vector3 bottomLeft2 = -Range2 / 2;

        Debug.DrawLine(Player.transform.position + topRight2, Player.transform.position + topLeft2, Color.yellow);
        Debug.DrawLine(Player.transform.position + topRight2, Player.transform.position + bottomRight2, Color.yellow);
        Debug.DrawLine(Player.transform.position + topLeft2, Player.transform.position + bottomLeft2, Color.yellow);
        Debug.DrawLine(Player.transform.position + bottomRight2, Player.transform.position + bottomLeft2, Color.yellow);

        Collider2D[] far = Physics2D.OverlapBoxAll(Player.transform.position, Vector2.one * farDis, 0f, LayerMask.GetMask("HurtBox"));
        Collider2D[] near = Physics2D.OverlapBoxAll(Player.transform.position, Vector2.one * nearDis, 0f, LayerMask.GetMask("HurtBox"));

        //把沒記錄過的加入PietaTargets
        foreach (Collider2D target in far)
        {
            if (target == Player.HurtBox)
                continue;

            bool hasTarget = false;
            foreach (PietaTarget pietaTarget in PietaTargets)
            {
                if (pietaTarget.Collider2D == target) 
                {
                    hasTarget = true;
                    break;
                }
            }
            if(!hasTarget) PietaTargets.Add(new PietaTarget(target, Appear(target.transform, HintPrefab)));
        }

        RaycastHit2D[] FacingTargets = CanPietaRange(nearDis / 2);

        List<PietaTarget> disappearList = new List<PietaTarget>();

        //把離開範圍內的標記刪除、更新標記圖示
        foreach (PietaTarget pietaTarget in PietaTargets)
        {
            if (!far.Contains(pietaTarget.Collider2D))
            {
                disappearList.Add(pietaTarget);
                continue;
            }

            if (near.Contains(pietaTarget.Collider2D))
            {
                bool Facing = false;
                if (FacingTargets.Length > 1)//不只射到自己
                {
                    foreach (RaycastHit2D FacingTarget in FacingTargets)
                    {
                        if (FacingTarget.collider == pietaTarget.Collider2D)
                        {
                            Facing = true;
                            break;
                        }
                    }
                }

                if (Facing)
                    //可觸發
                    pietaTarget.Hint.sprite = HintSprites[2];
                else
                    //近
                    pietaTarget.Hint.sprite = HintSprites[1];
            }
            else
            {
                //遠
                pietaTarget.Hint.sprite = HintSprites[0];
            }
        }

        foreach (PietaTarget pietaTarget in disappearList)
        {
            Disappear(pietaTarget);
        }
    }

    public bool CheckPietaAttack(Character _m)
    {
        CanPietaList = new List<PietaTarget>();

        //取所有可聖殤目標
        foreach (PietaTarget pietaTarget in PietaTargets)
        {
            if (pietaTarget.Hint.sprite == HintSprites[2])
            {
                pietaTarget.SlicePos = pietaTarget.Collider2D.transform.position;
                CanPietaList.Add(pietaTarget);
            }
        }

        PietaEndDis = Vector2.zero;
        FarestTargetCollider2D = null;

        if (CanPietaList.Count <= 0)
            return false;

        //取最遠可聖殤目標
        float dis = 0;
        foreach (PietaTarget pietaTarget in CanPietaList)
        {
            float newDis = Vector2.Distance(Player.transform.position, pietaTarget.Collider2D.transform.position);
            if (dis < newDis) 
            {
                dis = newDis;
                FarestTargetCollider2D = pietaTarget.Collider2D;
            }
        }

        return true;
    }


}

public class PietaTarget
{
    public Collider2D Collider2D;

    public SpriteRenderer Hint;

    public Vector2 SlicePos;

    public PietaTarget(Collider2D _collider2D, SpriteRenderer _Hint = null)
    {
        Collider2D = _collider2D;
        Hint = _Hint;
    }
}
