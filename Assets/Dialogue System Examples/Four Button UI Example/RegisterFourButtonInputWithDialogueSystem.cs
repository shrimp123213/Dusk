using UnityEngine;

namespace PixelCrushers.DialogueSystem
{

    /// <summary>
    /// This class registers the inputs in FourButtonInputActions with the 
    /// Dialogue System's Input Device Manager so the Dialogue System can
    /// read their values.
    /// </summary>
    public class RegisterFourButtonInputWithDialogueSystem : MonoBehaviour
    {

        private @FourButtonInputActions controls;

        // Track which instance of this script registered the inputs, to prevent
        // another instance from accidentally unregistering them.
        protected static bool isRegistered = false;
        private bool didIRegister = false;

        void Awake()
        {
            controls = new @FourButtonInputActions();
        }

        void OnEnable()
        {
            if (!isRegistered)
            {
                isRegistered = true;
                didIRegister = true;
                controls.Enable();
                InputDeviceManager.RegisterInputAction("A", controls.DialogueMap.A);
                InputDeviceManager.RegisterInputAction("B", controls.DialogueMap.B);
                InputDeviceManager.RegisterInputAction("X", controls.DialogueMap.X);
                InputDeviceManager.RegisterInputAction("Y", controls.DialogueMap.Y);
            }
        }

        void OnDisable()
        {
            if (didIRegister)
            {
                isRegistered = false;
                didIRegister = false;
                controls.Disable();
                InputDeviceManager.UnregisterInputAction("A");
                InputDeviceManager.UnregisterInputAction("B");
                InputDeviceManager.UnregisterInputAction("X");
                InputDeviceManager.UnregisterInputAction("Y");
            }
        }
    }
}
