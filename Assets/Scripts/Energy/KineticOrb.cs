using System.Collections;
using UnityEngine;

public class KineticOrb : MonoBehaviour
{
    public void StartAction()
    {
        base.transform.localScale = Vector3.one;
        GetComponent<Animator>().SetInteger("State", 1);
        StartCoroutine(Action());
        Object.Destroy(base.gameObject, 1.5f);
    }

    private IEnumerator Action()
    {
        yield return new WaitForSeconds(0.65f);
        GetComponent<Rigidbody2D>().simulated = true;
    }
}
