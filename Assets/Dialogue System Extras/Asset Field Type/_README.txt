This package adds a custom "Asset" field type that allows you to assign
assets (sprites, audio clips, ScriptableObject assets, etc.) to fields.

The scripts have comments that explain how they work. Briefly: this
custom field type relies on a ScriptableObject asset named 
DialogueAssetCatalog that is placed in a Resources folder. The first
time you assign an asset to an Asset field, it will create the 
DialogueAssetCatalog containing entries of the form:

<guid, asset>

where guid is the Unity GUID of the asset.

The field itself records the asset's GUID.

To look up an asset at runtime, call DialogueAssetCatalog.Lookup(guid).

To see it in action, import ExampleFiles.unitypackage. When you're
done examining the example files, delete the Example folder. It
has an example DialogueAssetCatalog that would otherwise interfere
with your own DialogueAssetCatalog.
