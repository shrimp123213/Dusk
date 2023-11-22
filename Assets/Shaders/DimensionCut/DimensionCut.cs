using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class DimensionCut : MonoBehaviour {
    [SerializeField] private Material mat;
    [SerializeField] private float speed;
    private bool pressing;
    private Vector2 start;
    private Vector2 end;
    private float offset;

    private void OnRenderImage(RenderTexture source, RenderTexture destination) {
        Graphics.Blit(source, destination, mat);
    }

    private void Update() {
        if (Input.GetMouseButtonDown(0) == true) {
            pressing = true;
            start = Input.mousePosition;
        }
        if (Input.GetMouseButtonUp(0) == true) {
            pressing = false;
            end = Input.mousePosition;
            mat.SetVector("_Pos", new Vector4(start.x / Screen.width, start.y / Screen.height, 0, 0));
            Vector2 delta = end - start;
            mat.SetFloat("_Angle", Mathf.Atan2(delta.y, delta.x) * Mathf.Rad2Deg);
            offset = -0.2f;
        }
        offset = Mathf.Min(0, offset + Time.deltaTime * speed);
        mat.SetFloat("_Offset", offset);
    }
}
