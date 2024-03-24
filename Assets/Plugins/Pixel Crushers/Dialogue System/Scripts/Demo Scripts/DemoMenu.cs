using UnityEngine;
using UnityEngine.Events;
using PixelCrushers.DialogueSystem.UnityGUI;

namespace PixelCrushers.DialogueSystem.Demo
{
    // 主選單腳本
    public class DemoMenu : MonoBehaviour
    {
        // 開始遊戲時的提示訊息
        public string startMessage = "Press Escape for Menu";
        // 打開選單的按鍵
        public KeyCode menuKey = KeyCode.Escape;
        // GUI的皮膚
        public GUISkin guiSkin;
        // 當任務日誌打開時是否關閉選單
        public bool closeWhenQuestLogOpen = true;
        // 遊戲進行時是否鎖定滑鼠
        public bool lockCursorDuringPlay = false;

        // 開啟和關閉選單時的事件
        public UnityEvent onOpen = new UnityEvent();
        public UnityEvent onClose = new UnityEvent();

        // 任務日誌窗口
        private QuestLogWindow questLogWindow = null;
        // 選單是否打開
        private bool isMenuOpen = false;
        // 選單窗口的位置和大小
        private Rect windowRect = new Rect(0, 0, 500, 500);
        // 選單窗口的縮放位置
        private ScaledRect scaledRect = ScaledRect.FromOrigin(ScaledRectAlignment.MiddleCenter, ScaledValue.FromPixelValue(300), ScaledValue.FromPixelValue(320));

        // 遊戲開始時的初始化
        void Start()
        {
            // 尋找任務日誌窗口
            if (questLogWindow == null) questLogWindow = GameObjectUtility.FindFirstObjectByType<QuestLogWindow>();
            // 顯示開始提示訊息
            if (!string.IsNullOrEmpty(startMessage)) DialogueManager.ShowAlert(startMessage);
        }

        // 物件被銷毀時的操作
        private void OnDestroy()
        {
            // 如果選單打開，則恢復遊戲時間
            if (isMenuOpen) Time.timeScale = 1;
        }

        // 每幀更新
        void Update()
        {
            // 如果按下選單按鍵，且對話和任務日誌都未打開，則切換選單狀態
            if (InputDeviceManager.IsKeyDown(menuKey) && !DialogueManager.isConversationActive && !IsQuestLogOpen())
            {
                SetMenuStatus(!isMenuOpen);
            }
            // 如果遊戲進行時鎖定滑鼠，則在對話、選單或任務日誌打開時解鎖滑鼠
            if (lockCursorDuringPlay)
            {
                CursorControl.SetCursorActive(DialogueManager.isConversationActive || isMenuOpen || IsQuestLogOpen());
            }
        }

        // GUI繪製
        void OnGUI()
        {
            // 如果選單打開且任務日誌未打開，則繪製選單窗口
            if (isMenuOpen && !IsQuestLogOpen())
            {
                if (guiSkin != null)
                {
                    GUI.skin = guiSkin;
                }
                windowRect = GUI.Window(0, windowRect, WindowFunction, "Menu");
            }
        }

        // 選單窗口的功能
        private void WindowFunction(int windowID)
        {
            // 繪製各種按鈕，並綁定相應的功能
            if (GUI.Button(new Rect(10, 60, windowRect.width - 20, 48), "Quest Log"))
            {
                if (closeWhenQuestLogOpen) SetMenuStatus(false);
                OpenQuestLog();
            }
            if (GUI.Button(new Rect(10, 110, windowRect.width - 20, 48), "Save Game"))
            {
                SetMenuStatus(false);
                SaveGame();
            }
            if (GUI.Button(new Rect(10, 160, windowRect.width - 20, 48), "Load Game"))
            {
                SetMenuStatus(false);
                LoadGame();
            }
            if (GUI.Button(new Rect(10, 210, windowRect.width - 20, 48), "Clear Saved Game"))
            {
                SetMenuStatus(false);
                ClearSavedGame();
            }
            if (GUI.Button(new Rect(10, 260, windowRect.width - 20, 48), "Close Menu"))
            {
                SetMenuStatus(false);
            }
        }

        // 打開選單
        public void Open()
        {
            SetMenuStatus(true);
        }

        // 關閉選單
        public void Close()
        {
            SetMenuStatus(false);
        }

        // 設置選單狀態
        private void SetMenuStatus(bool open)
        {
            isMenuOpen = open;
            if (open) windowRect = scaledRect.GetPixelRect();
            Time.timeScale = open ? 0 : 1;
            if (open) onOpen.Invoke(); else onClose.Invoke();
        }

        // 檢查任務日誌是否打開
        private bool IsQuestLogOpen()
        {
            return (questLogWindow != null) && questLogWindow.isOpen;
        }

        // 打開任務日誌
        private void OpenQuestLog()
        {
            if ((questLogWindow != null) && !IsQuestLogOpen())
            {
                questLogWindow.Open();
            }
        }

        // 保存遊戲
        private void SaveGame()
        {
            var saveSystem = GameObjectUtility.FindFirstObjectByType<SaveSystem>();
            if (saveSystem != null)
            {
                SaveSystem.SaveToSlot(1);
            }
            else
            {
                string saveData = PersistentDataManager.GetSaveData();
                PlayerPrefs.SetString("SavedGame", saveData);
                Debug.Log("Save Game Data: " + saveData);
            }
            DialogueManager.ShowAlert("Game saved.");
        }

        // 加載遊戲
        private void LoadGame()
        {
            PersistentDataManager.LevelWillBeUnloaded();
            var saveSystem = GameObjectUtility.FindFirstObjectByType<SaveSystem>();
            if (saveSystem != null)
            {
                if (SaveSystem.HasSavedGameInSlot(1))
                {
                    SaveSystem.LoadFromSlot(1);
                    DialogueManager.ShowAlert("Game loaded.");
                }
                else
                {
                    DialogueManager.ShowAlert("Save a game first.");
                }
            }
            else
            {
                if (PlayerPrefs.HasKey("SavedGame"))
                {
                    string saveData = PlayerPrefs.GetString("SavedGame");
                    Debug.Log("Load Game Data: " + saveData);
                    LevelManager levelManager = GameObjectUtility.FindFirstObjectByType<LevelManager>();
                    if (levelManager != null)
                    {
                        levelManager.LoadGame(saveData);
                    }
                    else
                    {
                        PersistentDataManager.ApplySaveData(saveData);
                        DialogueManager.SendUpdateTracker();
                    }
                    DialogueManager.ShowAlert("Game loaded.");
                }
                else
                {
                    DialogueManager.ShowAlert("Save a game first.");
                }
            }
        }

        // 清除保存的遊戲
        private void ClearSavedGame()
        {
            var saveSystem = GameObjectUtility.FindFirstObjectByType<SaveSystem>();
            if (saveSystem != null)
            {
                if (SaveSystem.HasSavedGameInSlot(1))
                {
                    SaveSystem.DeleteSavedGameInSlot(1);
                }
            }
            else if (PlayerPrefs.HasKey("SavedGame"))
            {
                PlayerPrefs.DeleteKey("SavedGame");
                Debug.Log("Cleared saved game data");
            }
            DialogueManager.ShowAlert("Saved Game Cleared");
        }
    }
}