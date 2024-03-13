using System;
using System.Collections.Generic;
using UnityEngine;

namespace PixelCrushers.DialogueSystem
{

    /// <summary>
    /// This ScriptableObject asset holds a catalog of assets
    /// that have been assigned to the "Asset" custom field type
    /// defined in CustomFieldType_Asset. The first time an
    /// asset is added to the catalog, it creates an instance
    /// if DialogueAssetCatalog for itself in a Resources folder.
    /// 
    /// To add an asset, call DialogueAssetCatalog.Add(asset),
    /// which is an editor only method.
    /// 
    /// To look up an asset at runtime or in editor, use 
    /// DialogueAssetCatalog.Lookup(guid).
    /// </summary>
    public class DialogueAssetCatalog : ScriptableObject
    {

        [Serializable]
        public class CatalogEntry
        {
            [SerializeField] private string guid;
            [SerializeField] private UnityEngine.Object asset;

            public string Guid => guid;
            public UnityEngine.Object Asset => asset;

            public CatalogEntry(string guid, UnityEngine.Object asset)
            {
                this.guid = guid;
                this.asset = asset;
            }
        }

        [SerializeField] private List<CatalogEntry> assets = new List<CatalogEntry>();
        public List<CatalogEntry> Assets => assets;

        private const string DialogueAssetCatalogName = "DialogueAssetCatalog";

        private static DialogueAssetCatalog instance = null;

        public static DialogueAssetCatalog Instance
        {
            get
            {
                if (instance == null)
                {
                    instance = Resources.Load<DialogueAssetCatalog>(DialogueAssetCatalogName);
#if UNITY_EDITOR
                    if (instance == null)
                    {
                        if (!UnityEditor.AssetDatabase.IsValidFolder("Assets/Resources"))
                        {
                            UnityEditor.AssetDatabase.CreateFolder("Assets", "Resources");
                        }
                        var assetPath = $"Assets/Resources/{DialogueAssetCatalogName}.asset";
                        instance = CreateInstance<DialogueAssetCatalog>();
                        UnityEditor.AssetDatabase.CreateAsset(instance, assetPath);
                        UnityEditor.AssetDatabase.SaveAssets();
                        UnityEditor.AssetDatabase.Refresh();
                    }
#endif
                }
                return instance;
            }
        }

#if UNITY_EDITOR

        [RuntimeInitializeOnLoadMethod(RuntimeInitializeLoadType.SubsystemRegistration)]
        static void InitStaticVariables()
        {
            instance = null;
        }

        public static void Add(UnityEngine.Object asset)
        {
            if (asset == null) return;
            if (Instance == null)
            {
                Debug.LogError($"Dialogue System: Can't load or create {DialogueAssetCatalogName}.asset. Not adding {asset} to asset catalog.", asset);
                return;
            }
            var guid = UnityEditor.AssetDatabase.AssetPathToGUID(UnityEditor.AssetDatabase.GetAssetPath(asset));
            if (string.IsNullOrEmpty(guid))
            {
                Debug.LogError($"Dialogue System: Can't determine GUID of {asset}. Not adding {asset} to asset catalog.", asset);
                return;
            }
            if (Instance.Assets.Find(entry => entry.Guid == guid) == null)
            {
                Instance.Assets.Add(new CatalogEntry(guid, asset));
                UnityEditor.EditorUtility.SetDirty(Instance);
            }
        }

        public static void Remove(string guid)
        {
            if (Instance == null)
            {
                Debug.LogError($"Dialogue System: Can't load or create {DialogueAssetCatalogName}.asset. Not removing GUID {guid} from asset catalog.");
                return;
            }
            Instance.Assets.RemoveAll(entry => entry.Guid == guid);
            UnityEditor.EditorUtility.SetDirty(Instance);
        }

#endif

        public static UnityEngine.Object Lookup(string guid)
        {
            if (string.IsNullOrEmpty(guid)) return null;
            if (Instance == null)
            {
                Debug.LogError($"Dialogue System: Can't load {DialogueAssetCatalogName}.asset. Not returning asset for GUID {guid}.");
                return null;
            }
            var entry = Instance.Assets.Find(entry => entry.Guid == guid);
            if (entry == null)
            {
                Debug.LogError($"Dialogue System: {DialogueAssetCatalogName}.asset doesn't contain an entry with GUID {guid}. Not returning asset.");
                return null;
            }
            return entry.Asset;
        }

    }

}
