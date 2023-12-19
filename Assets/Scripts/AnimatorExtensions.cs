using System.Collections.Generic;
using UnityEngine;

public static class AnimatorExtensions
{
    public static void RebindAndRetainAllState(this Animator anim)
    {
        List<AnimatorStateInfo> animStates = new List<AnimatorStateInfo>();
        for (int i = 0; i < anim.layerCount; i++)
        {
            animStates.Add(anim.GetCurrentAnimatorStateInfo(i));
        }

        List<AnimatorParameterInfo<bool>> animBoolParams = new List<AnimatorParameterInfo<bool>>();
        List<AnimatorParameterInfo<float>> animFloatParams = new List<AnimatorParameterInfo<float>>();
        List<AnimatorParameterInfo<int>> animIntParams = new List<AnimatorParameterInfo<int>>();
        foreach (var param in anim.parameters)
        {
            switch (param.type)
            {
                case (AnimatorControllerParameterType.Bool):
                    var boolParam = new AnimatorParameterInfo<bool>()
                    {
                        name = param.name,
                        value = anim.GetBool(param.name)
                    };
                    animBoolParams.Add(boolParam);
                    break;
                case (AnimatorControllerParameterType.Float):
                    var floatParam = new AnimatorParameterInfo<float>()
                    {
                        name = param.name,
                        value = anim.GetFloat(param.name)
                    };
                    animFloatParams.Add(floatParam);
                    break;
                case (AnimatorControllerParameterType.Int):
                    var intParam = new AnimatorParameterInfo<int>()
                    {
                        name = param.name,
                        value = anim.GetInteger(param.name)
                    };
                    animIntParams.Add(intParam);
                    break;
            }
        }

        anim.Rebind();

        for (int i = 0; i < anim.layerCount; i++)
        {
            anim.Play(animStates[i].fullPathHash, i, animStates[i].normalizedTime);
            //I've found .Play works better for me, but I think a CrossFade could work here too...
            //anim.CrossFade(animStates[i].fullPathHash, .2f, i, animStates[i].normalizedTime);
        }

        foreach (var param in animBoolParams)
        {
            anim.SetBool(param.name, param.value);
        }

        foreach (var param in animFloatParams)
        {
            anim.SetFloat(param.name, param.value);
        }

        foreach (var param in animIntParams)
        {
            anim.SetInteger(param.name, param.value);
        }
    }

    public static void RebindAndRetainParameter(this Animator anim)
    {
        List<AnimatorParameterInfo<bool>> animBoolParams = new List<AnimatorParameterInfo<bool>>();
        List<AnimatorParameterInfo<float>> animFloatParams = new List<AnimatorParameterInfo<float>>();
        List<AnimatorParameterInfo<int>> animIntParams = new List<AnimatorParameterInfo<int>>();
        foreach (var param in anim.parameters)
        {
            switch (param.type)
            {
                case (AnimatorControllerParameterType.Bool):
                    var boolParam = new AnimatorParameterInfo<bool>()
                    {
                        name = param.name,
                        value = anim.GetBool(param.name)
                    };
                    animBoolParams.Add(boolParam);
                    break;
                case (AnimatorControllerParameterType.Float):
                    var floatParam = new AnimatorParameterInfo<float>()
                    {
                        name = param.name,
                        value = anim.GetFloat(param.name)
                    };
                    animFloatParams.Add(floatParam);
                    break;
                case (AnimatorControllerParameterType.Int):
                    var intParam = new AnimatorParameterInfo<int>()
                    {
                        name = param.name,
                        value = anim.GetInteger(param.name)
                    };
                    animIntParams.Add(intParam);
                    break;
            }
        }

        anim.Rebind();

        foreach (var param in animBoolParams)
        {
            anim.SetBool(param.name, param.value);
        }

        foreach (var param in animFloatParams)
        {
            anim.SetFloat(param.name, param.value);
        }

        foreach (var param in animIntParams)
        {
            anim.SetInteger(param.name, param.value);
        }
    }

    private struct AnimatorParameterInfo<T>
    {
        public string name;
        public T value;
    }
}