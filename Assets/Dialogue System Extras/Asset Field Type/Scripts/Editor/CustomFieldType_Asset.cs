using System.Collections.Generic;
using UnityEngine;
using UnityEditor;

namespace PixelCrushers.DialogueSystem
{

    /// <summary>
    /// This custom field type stores the GUID of an asset.
    /// The GUID is also stored in a custom DialogueAssetCatalog
    /// ScriptableObject asset in a Resources folder.
    /// </summary>
    [CustomFieldTypeService.Name("Asset")]
    public class CustomFieldType_Asset : CustomFieldType
    {

        public override string Draw(string guid, DialogueDatabase database)
        {
            var asset = DialogueAssetCatalog.Lookup(guid);
            EditorGUI.BeginChangeCheck();
            asset = EditorGUILayout.ObjectField(asset, typeof(UnityEngine.Object), false);
            if (EditorGUI.EndChangeCheck())
            {
                guid = UpdateAsset(guid, asset, database);
            }
            return guid;
        }

        public override string Draw(Rect rect, string guid, DialogueDatabase database)
        {
            var asset = DialogueAssetCatalog.Lookup(guid);
            EditorGUI.BeginChangeCheck();
            asset = EditorGUI.ObjectField(rect, asset, typeof(UnityEngine.Object), false);
            if (EditorGUI.EndChangeCheck())
            {
                guid = UpdateAsset(guid, asset, database);
            }
            return guid;
        }

        private string UpdateAsset(string guid, UnityEngine.Object asset, DialogueDatabase database)
        {
            RemoveEntryIfOnlyOneReference(guid, database);
            if (asset == null)
            {
                guid = string.Empty;
            }
            else
            {
                guid = AssetDatabase.AssetPathToGUID(AssetDatabase.GetAssetPath(asset));
                DialogueAssetCatalog.Add(asset);
            }
            return guid;
        }

        private void RemoveEntryIfOnlyOneReference(string guid, DialogueDatabase database)
        {
            if (string.IsNullOrEmpty(guid)) return;
            if (!HasMultipleReferences(guid, database))
            {
                DialogueAssetCatalog.Remove(guid);
            }
        }

        private bool HasMultipleReferences(string guid, DialogueDatabase database)
        {
            var count = GetGuidCount<Actor>(0, database.actors, guid, database);
            if (count >= 2) return true;
            count = GetGuidCount<Item>(count, database.items, guid, database);
            if (count >= 2) return true;
            count = GetGuidCount<Location>(count, database.locations, guid, database);
            if (count >= 2) return true;
            count = GetGuidCount<Conversation>(count, database.conversations, guid, database);
            if (count >= 2) return true;
            foreach (var conversation in database.conversations)
            {
                foreach (var entry in conversation.dialogueEntries)
                {
                    foreach (var field in entry.fields)
                    {
                        if (field.typeString == nameof(CustomFieldType_Asset) && field.value == guid)
                        {
                            count++;
                            if (count >= 2) return true;
                        }
                    }
                }
            }
            return false;
        }

        private int GetGuidCount<T>(int count, List<T> assets, string guid, DialogueDatabase database) where T : Asset
        {
            foreach (var actor in assets)
            {
                foreach (var field in actor.fields)
                {
                    if (field.typeString == nameof(CustomFieldType_Asset) && field.value == guid)
                    {
                        count++;
                        if (count > 1) return 2;
                    }
                }
            }
            return count;
        }

    }
}
