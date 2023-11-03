using UnityEngine;
using System.Collections;
using System.Collections.Generic;
using System.Linq;

// 残影效果  
public class AfterImageComponent : MonoBehaviour
{
    class AfterImage
    {
        public Mesh mesh;
        public Material material;
        public float showStartTime;
        public float duration;  // 残影镜像存在时间  
        public float alpha;
        public bool needRemove = false;
        public Quaternion quat;
        public Vector3 pos;
    }

    private float _duration; // 残影特效持续时间  
    private float _interval; // 间隔  
    private float _fadeTime; // 淡出时间  

    private List<AfterImage> _imageList = new List<AfterImage>();
    private Shader _shaderAfterImage;

    void Awake()
    {
        _shaderAfterImage = Shader.Find("Muffin/MuffinPhantom");
    }

    public void Play(float duration, float interval, float fadeout)
    {
        _duration = duration;
        _interval = interval;
        _fadeTime = fadeout;

        StartCoroutine(DoAddImage());
    }

    IEnumerator DoAddImage()
    {
        float startTime = Time.realtimeSinceStartup;
        while (true)
        {
            CreateImage();

            if (Time.realtimeSinceStartup - startTime > _duration)
            {
                break;
            }

            yield return new WaitForSeconds(_interval);
        }
    }

    private void CreateImage()
    {
        // 获取skin mesh
        SkinnedMeshRenderer[] renderers = GetComponentsInChildren<SkinnedMeshRenderer>();

        Transform t = transform;
        Material mat = null;
        for (int i = 0; i < renderers.Length; ++i)
        {
            var item = renderers[i];
            var tK = item.transform;

            // 创建残影材质球
            //mat = new Material(_shaderAfterImage);
            //mat.SetTexture("_normalMap", item.material.GetTexture("_NormalTex"));
            mat = item.material;

            // bake skin mesh。 这里因为DrawMesh不能画出skin mesh。所以先bake成普通mesh
            var mesh = new Mesh();
            item.BakeMesh(mesh);

            // 这里处理动画旋转的问题。 因为用到了scale.x = -1 来旋转动画，这里做了旋转
            var count = mesh.vertexCount;
            var tmp = mesh.vertices;
            var baseScalex = tK.lossyScale.x;
            for (int j = 0; j < count; j++)
            {
                // 这里注意不要用mesh.vertices 要不效率会超低
                tmp[j].x *= baseScalex;
            }
            mesh.RecalculateBounds();
            mesh.RecalculateNormals();

            // 加入显示队列
            _imageList.Add(new AfterImage
            {
                mesh = mesh,
                material = mat,
                showStartTime = Time.realtimeSinceStartup,
                duration = _fadeTime,
                quat = tK.transform.rotation,
                pos = tK.transform.position
            });

        }
    }

    void LateUpdate()
    {
        bool hasRemove = false;
        foreach (var item in _imageList)
        {
            float time = Time.realtimeSinceStartup - item.showStartTime;

            if (time > item.duration)
            {
                item.needRemove = true;
                hasRemove = true;
                continue;
            }

            Graphics.DrawMesh(item.mesh, item.pos, item.quat, item.material, gameObject.layer);
        }

        if (hasRemove)
        {
            _imageList.RemoveAll(x => x.needRemove);
        }
    }
}