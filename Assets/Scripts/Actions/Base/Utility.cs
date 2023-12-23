using UnityEngine;

public class Vector3Utility : MonoBehaviour
{
    public static int GetFacingByPos(Transform _T1, Transform _T2)
    {
        if (!(_T1.position.x - _T2.position.x < 0f))
        {
            return -1;
        }
        return 1;
    }

    public static Vector3 CacuFacing(Vector3 _input, int _Facing)
    {
        return new Vector3(_input.x * (float)_Facing, _input.y, _input.z);
    }

    public static bool IsFacing(int _Facing, float _way)
    {
        if (_Facing <= 0)
        {
            return _way < 0f;
        }
        return _way > 0f;
    }

    public static Vector2 CacuVector2Curve(Vector2 _Power, AnimationCurve _XCurve, AnimationCurve _YCurve, float _time)
    {
        return new Vector2(_XCurve.Evaluate(_time) * _Power.x, _YCurve.Evaluate(_time) * _Power.y);
    }
}

public class InputUtility : MonoBehaviour
{
    public static InputKey GetHighestAxis(float x, float y)
    {
        float num = Mathf.Abs(x);
        float num2 = Mathf.Abs(y);
        if (num <= 0.45f && num2 <= 0.45f)
        {
            return InputKey.None;
        }
        if (num > num2)
        {
            if (x > 0f)
            {
                return InputKey.Right;
            }
            return InputKey.Left;
        }
        if (y > 0f)
        {
            return InputKey.Up;
        }
        return InputKey.Down;
    }
}

public class TransformUtility : MonoBehaviour
{
    public static Transform FindTransform(Transform parent, string name)
    {
        if (parent.name.Equals(name)) return parent;
        foreach (Transform child in parent)
        {
            Transform result = FindTransform(child, name);
            if (result != null) return result;
        }
        return null;
    }
}