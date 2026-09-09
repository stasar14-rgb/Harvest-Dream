class_name ItemDatabase
extends Node

## Gegenstandskatalog, aus dem die zentrale Datenbank ihre Einträge lädt.
@export var catalog: ItemCatalog

func _ready() -> void:
	if catalog == null:
		push_error("ItemDatabase besitzt keinen Gegenstandskatalog.")
		return

	catalog.rebuild_index()

func get_item(item_id: StringName) -> ItemData:
	if catalog == null:
		return null

	return catalog.get_item(item_id)

func has_item(item_id: StringName) -> bool:
	return get_item(item_id) != null

func get_item_count() -> int:
	if catalog == null:
		return 0

	return catalog.get_item_count()
