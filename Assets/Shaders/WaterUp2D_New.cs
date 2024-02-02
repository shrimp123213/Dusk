using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class WaterUp2D_New : MonoBehaviour
{
    /*//2d水上涨效果：
    1.以需要长宽，创建纹理
   
    4.定义水面高度参数   
    5.对满足水面高度的点，按照uv.x的值来进行sin函数变换，记录 最终高度值
    6.对高于该值的赋予无水颜色，低于该值的赋予水颜色。

    2.对纹理取 需要轮廓（圆形，圆心在中心，半径为最短边的一半）
    3.对轮廓外的部分透明，轮廓内的部分 颜色采样

    */

    public Shader _shader;

    public Material material;
    
    public int textureWidth;
    public int textureHeight;
    RenderTexture createTexture;
    RenderTexture createTexture2;

    public RenderTexture outTexture;

    [Range(0,1)]
    public float waterHeight;
    [Range(0,10)]
    public float wave;

    [Range(-10, 10)]
    public float speed;
    [Range(0, 100)]
    public float t;


    public Color color;

    bool isshaderenable = false;
    public void CreateShaderNeed(int width,int height)
    {
        //创建材质
        if (_shader != null)
        {
            material = new Material(_shader);
        }
        else
        {
            Debug.LogError("缺少shader,材质创建失败！");
            return;
        }
        textureWidth = width;
        textureHeight = height;
        //创建初始纹理
        createTexture = new RenderTexture(textureWidth, textureHeight, 0, RenderTextureFormat.ARGB32);
        createTexture.Create();
        //创建output纹理
        outTexture = new RenderTexture(textureWidth, textureHeight, 0, RenderTextureFormat.ARGB32);
        outTexture.Create();

        isshaderenable = true;
    }

    public void SetState(float height,float wave,float speed,float t)
    {
        waterHeight = height;
        this.wave = wave;
        this.speed = speed;
        this.t = t;
    }

    // Start is called before the first frame update
    //void Start()
    //{
    //    if (outTexture != null)
    //    {
    //        textureWidth = outTexture.width;
    //        textureHeight = outTexture.height;
    //    }

    //    if (material != null)
    //    {
    //        createTexture = new RenderTexture(textureWidth, textureHeight, 0, RenderTextureFormat.ARGB32);
    //        createTexture.Create();
    //    }
    //}

    // Update is called once per frame
    void Update()
    {
        if (isshaderenable)
        {
            if (material != null)
            {
                material.SetFloat("_WaterHeight", waterHeight);
                material.SetFloat("_Wave", wave);
                material.SetColor("_Clo", color);
                material.SetFloat("_Speed", speed);
                material.SetFloat("_T", t);
                Graphics.Blit(createTexture, outTexture, material, 0);
            }
        }
       
    }
}