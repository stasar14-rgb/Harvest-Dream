class_name ItemCatalog
extends Resource

@export var items: Array[ItemData] = []

var _items_by_id: Dictionary = {}

func rebuild_index() -> bool:
	_items_by_id.clear()
	var catalog_is_valid := true

	for item in items:
		if item == null:
			push_error("Der Gegenstandskatalog enthält einen leeren Eintrag.")
			catalog_is_valid = false
			continue

		if not item.is_valid_definition():
			catalog_is_valid = false
			continue

		if _items_by_id.has(item.item_id):
			push_error("Die Gegenstands-ID '%s' ist doppelt vorhanden." % item.item_id)
			catalog_is_valid = false
			continue

		_items_by_id[item.item_id] = item

	return catalog_is_valid

func get_item(item_id: StringName) -> ItemData:
	if _items_by_id.is_empty() and not items.is_empty():
		rebuild_index()

	return _items_by_id.get(item_id) as ItemData

func has_item(item_id: StringName) -> bool:
	return get_item(item_id) != null

func get_item_count() -> int:
	return items.size()

func get_all_items() -> Array[ItemData]:
	return items.duplicate()
