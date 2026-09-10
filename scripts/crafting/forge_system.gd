class_name ForgeSystem
extends Node

signal storage_changed
signal queue_changed
signal progress_changed(progress_ratio: float)
signal crafting_completed(recipe: CraftingRecipe, amount: int)
signal operation_rejected(message: String)
signal station_unlocked_changed(is_unlocked: bool)

## Gemeinsame Anzahl der Lagerplätze für Rohstoffe und fertige Gegenstände.
@export_range(1, 200, 1) var storage_capacity: int = 20
## Alle Rezepte, die in dieser Schmiede angeboten werden.
@export var available_recipes: Array[CraftingRecipe] = []
## Legt fest, ob die Schmiede bereits gebaut und benutzbar ist.
@export var station_unlocked: bool = false

var storage_slots: Array[InventorySlot] = []
var _queue: Array[Dictionary] = []
var _reserved_amounts: Dictionary = {}
var _progress_seconds: float = 0.0
var _recipes_by_id: Dictionary = {}
var _item_database: ItemDatabase
var _inventory_system: InventorySystem
var _profession_system: ProfessionSystem
var _output_blocked: bool = false

func _ready() -> void:
	_item_database = get_tree().get_first_node_in_group(&"item_database") as ItemDatabase
	_inventory_system = get_tree().get_first_node_in_group(&"inventory_system") as InventorySystem
	_profession_system = get_tree().get_first_node_in_group(&"profession_system") as ProfessionSystem
	if _item_database == null or _inventory_system == null or _profession_system == null:
		push_error("ForgeSystem findet Gegenstands-, Inventar- oder Berufssystem nicht.")
		return
	_resize_storage()
	_rebuild_recipe_index()

func _process(delta: float) -> void:
	if _queue.is_empty():
		return
	var recipe := get_current_recipe()
	if recipe == null:
		_cancel_invalid_current_entry()
		return

	_progress_seconds = minf(_progress_seconds + delta, recipe.crafting_seconds)
	progress_changed.emit(get_progress_ratio())
	if _progress_seconds < recipe.crafting_seconds:
		return
	if not _can_complete_one(recipe):
		if not _output_blocked:
			_output_blocked = true
			operation_rejected.emit("Das Schmiedelager ist voll. Die Herstellung wartet auf einen freien Platz.")
		return

	_output_blocked = false
	_complete_one(recipe)

func unlock_station() -> void:
	if station_unlocked:
		return
	station_unlocked = true
	station_unlocked_changed.emit(true)

func get_recipes() -> Array[CraftingRecipe]:
	return available_recipes.duplicate()

func get_recipe(recipe_id: StringName) -> CraftingRecipe:
	return _recipes_by_id.get(recipe_id) as CraftingRecipe

func get_storage_slots() -> Array[InventorySlot]:
	return storage_slots

func get_stored_amount(item_id: StringName) -> int:
	var total := 0
	for slot in storage_slots:
		if slot.item_id == item_id:
			total += slot.amount
	return total

func get_reserved_amount(item_id: StringName) -> int:
	return int(_reserved_amounts.get(item_id, 0))

func get_available_storage_amount(item_id: StringName) -> int:
	return maxi(get_stored_amount(item_id) - get_reserved_amount(item_id), 0)

func get_owned_available_amount(item_id: StringName) -> int:
	return get_available_storage_amount(item_id) + _inventory_system.get_item_amount(item_id)

func get_max_craftable(recipe_id: StringName) -> int:
	var recipe := get_recipe(recipe_id)
	if recipe == null or not station_unlocked:
		return 0
	var material_limit := 999999
	for index in recipe.ingredient_item_ids.size():
		var owned_amount := get_owned_available_amount(recipe.ingredient_item_ids[index])
		material_limit = mini(
			material_limit,
			floori(float(owned_amount) / float(recipe.ingredient_amounts[index]))
		)
	if material_limit <= 0:
		return 0

	var low := 0
	var high := material_limit
	while low < high:
		var middle := floori(float(low + high + 1) / 2.0)
		if _can_queue_recipe(recipe, middle):
			low = middle
		else:
			high = middle - 1
	return low

func request_crafting(recipe_id: StringName, requested_amount: int) -> bool:
	if not station_unlocked:
		operation_rejected.emit("Die Schmiede wurde noch nicht gebaut.")
		return false
	var recipe := get_recipe(recipe_id)
	if recipe == null or requested_amount <= 0:
		operation_rejected.emit("Dieser Herstellungsauftrag ist ungültig.")
		return false
	if not _can_queue_recipe(recipe, requested_amount):
		operation_rejected.emit("Material oder Platz im Schmiedelager reicht für diese Menge nicht aus.")
		return false

	var required_materials := _get_required_materials(recipe, requested_amount)
	var transferred_materials: Dictionary = {}
	for item_id_value in required_materials:
		var item_id := item_id_value as StringName
		var required_amount := int(required_materials[item_id])
		var storage_amount := get_available_storage_amount(item_id)
		var transfer_amount := maxi(required_amount - storage_amount, 0)
		if transfer_amount > 0:
			if not _inventory_system.remove_item(item_id, transfer_amount):
				_rollback_inventory_transfers(transferred_materials)
				operation_rejected.emit("Die benötigten Materialien konnten nicht übertragen werden.")
				return false
			_add_to_storage(item_id, transfer_amount)
			transferred_materials[item_id] = transfer_amount
	for item_id_value in required_materials:
		var item_id := item_id_value as StringName
		var required_amount := int(required_materials[item_id])
		_reserved_amounts[item_id] = get_reserved_amount(item_id) + required_amount

	_queue.append({
		"recipe_id": recipe.recipe_id,
		"total_amount": requested_amount,
		"remaining_amount": requested_amount,
	})
	queue_changed.emit()
	storage_changed.emit()
	return true

func cancel_current_batch() -> bool:
	if _queue.is_empty():
		return false
	var entry := _queue[0]
	var recipe := get_recipe(StringName(entry.get("recipe_id", "")))
	var remaining_amount := maxi(int(entry.get("remaining_amount", 0)), 0)
	if recipe != null:
		_release_recipe_reservations(recipe, remaining_amount)
	_queue.pop_front()
	_progress_seconds = 0.0
	_output_blocked = false
	queue_changed.emit()
	storage_changed.emit()
	progress_changed.emit(get_progress_ratio())
	return true

func transfer_storage_slot_to_inventory(slot_index: int) -> bool:
	if slot_index < 0 or slot_index >= storage_slots.size():
		return false
	var slot := storage_slots[slot_index]
	if slot.is_empty():
		return false
	var available_amount := get_available_storage_amount(slot.item_id)
	var transferable_amount := mini(
		slot.amount,
		mini(available_amount, _inventory_system.get_free_capacity_for(slot.item_id))
	)
	if transferable_amount <= 0:
		operation_rejected.emit("Dieser Stapel ist reserviert oder das Inventar ist voll.")
		return false
	if not _inventory_system.try_add_item(slot.item_id, transferable_amount):
		return false
	slot.set_stack(slot.item_id, slot.amount - transferable_amount)
	storage_changed.emit()
	return true

func get_current_recipe() -> CraftingRecipe:
	if _queue.is_empty():
		return null
	return get_recipe(StringName(_queue[0].get("recipe_id", "")))

func get_current_total_amount() -> int:
	return 0 if _queue.is_empty() else int(_queue[0].get("total_amount", 0))

func get_current_completed_amount() -> int:
	if _queue.is_empty():
		return 0
	return get_current_total_amount() - int(_queue[0].get("remaining_amount", 0))

func get_progress_ratio() -> float:
	var recipe := get_current_recipe()
	if recipe == null:
		return 0.0
	return clampf(_progress_seconds / recipe.crafting_seconds, 0.0, 1.0)

func get_forge_data() -> Dictionary:
	var stored_items: Array[Dictionary] = []
	for slot in storage_slots:
		stored_items.append({"item_id": slot.item_id, "amount": slot.amount})
	return {
		"station_unlocked": station_unlocked,
		"storage": stored_items,
		"queue": _queue.duplicate(true),
		"progress_seconds": _progress_seconds,
	}

func load_forge_data(data: Dictionary) -> void:
	station_unlocked = bool(data.get("station_unlocked", false))
	_resize_storage()
	for slot in storage_slots:
		slot.clear()
	var stored_items_value: Variant = data.get("storage", [])
	if stored_items_value is Array:
		var stored_items: Array = stored_items_value
		for index in mini(stored_items.size(), storage_slots.size()):
			if not stored_items[index] is Dictionary:
				continue
			var entry: Dictionary = stored_items[index]
			var item_id := StringName(entry.get("item_id", ""))
			var amount := maxi(int(entry.get("amount", 0)), 0)
			if _item_database.has_item(item_id):
				storage_slots[index].set_stack(item_id, amount)

	_queue.clear()
	var queue_value: Variant = data.get("queue", [])
	if queue_value is Array:
		var saved_queue: Array = queue_value
		for entry_value in saved_queue:
			if not entry_value is Dictionary:
				continue
			var entry: Dictionary = entry_value
			var recipe_id := StringName(entry.get("recipe_id", ""))
			var total_amount := maxi(int(entry.get("total_amount", 0)), 0)
			var remaining_amount := clampi(
				int(entry.get("remaining_amount", 0)),
				0,
				total_amount
			)
			if get_recipe(recipe_id) != null and remaining_amount > 0:
				_queue.append({
					"recipe_id": recipe_id,
					"total_amount": total_amount,
					"remaining_amount": remaining_amount,
				})
	_progress_seconds = maxf(float(data.get("progress_seconds", 0.0)), 0.0)
	_rebuild_reservations_from_queue()
	station_unlocked_changed.emit(station_unlocked)
	storage_changed.emit()
	queue_changed.emit()
	progress_changed.emit(get_progress_ratio())

func _complete_one(recipe: CraftingRecipe) -> void:
	_consume_recipe_materials(recipe)
	_add_to_storage(recipe.output_item_id, recipe.output_amount)
	var entry := _queue[0]
	var remaining_amount := maxi(int(entry.get("remaining_amount", 1)) - 1, 0)
	entry["remaining_amount"] = remaining_amount
	_queue[0] = entry
	_progress_seconds = 0.0
	_profession_system.award_forged_item()
	crafting_completed.emit(recipe, recipe.output_amount)
	storage_changed.emit()
	if remaining_amount == 0:
		_queue.pop_front()
		queue_changed.emit()
	else:
		queue_changed.emit()
	progress_changed.emit(get_progress_ratio())

func _can_queue_recipe(recipe: CraftingRecipe, amount: int) -> bool:
	if amount <= 0:
		return false
	var required_materials := _get_required_materials(recipe, amount)
	var simulated_slots := _duplicate_slots(storage_slots)
	for item_id_value in required_materials:
		var item_id := item_id_value as StringName
		var required_amount := int(required_materials[item_id])
		var storage_available := get_available_storage_amount(item_id)
		var transfer_amount := maxi(required_amount - storage_available, 0)
		if _inventory_system.get_item_amount(item_id) < transfer_amount:
			return false
		if _add_to_slots(simulated_slots, item_id, transfer_amount) > 0:
			return false
	return true

func _can_complete_one(recipe: CraftingRecipe) -> bool:
	var simulated_slots := _duplicate_slots(storage_slots)
	for index in recipe.ingredient_item_ids.size():
		if _remove_from_slots(
			simulated_slots,
			recipe.ingredient_item_ids[index],
			recipe.ingredient_amounts[index]
		) > 0:
			return false
	return _add_to_slots(simulated_slots, recipe.output_item_id, recipe.output_amount) == 0

func _consume_recipe_materials(recipe: CraftingRecipe) -> void:
	for index in recipe.ingredient_item_ids.size():
		var item_id := recipe.ingredient_item_ids[index]
		var amount := recipe.ingredient_amounts[index]
		_remove_from_slots(storage_slots, item_id, amount)
		_reserved_amounts[item_id] = maxi(get_reserved_amount(item_id) - amount, 0)

func _release_recipe_reservations(recipe: CraftingRecipe, amount: int) -> void:
	for index in recipe.ingredient_item_ids.size():
		var item_id := recipe.ingredient_item_ids[index]
		var released_amount := recipe.ingredient_amounts[index] * amount
		_reserved_amounts[item_id] = maxi(get_reserved_amount(item_id) - released_amount, 0)

func _get_required_materials(recipe: CraftingRecipe, amount: int) -> Dictionary:
	var required_materials: Dictionary = {}
	for index in recipe.ingredient_item_ids.size():
		var item_id := recipe.ingredient_item_ids[index]
		var ingredient_total := recipe.ingredient_amounts[index] * amount
		required_materials[item_id] = int(required_materials.get(item_id, 0)) + ingredient_total
	return required_materials

func _resize_storage() -> void:
	while storage_slots.size() < storage_capacity:
		storage_slots.append(InventorySlot.new())

func _rebuild_recipe_index() -> void:
	_recipes_by_id.clear()
	for recipe in available_recipes:
		if recipe == null or not recipe.is_valid_definition():
			continue
		if _recipes_by_id.has(recipe.recipe_id):
			push_error("Schmiederezept-ID '%s' ist doppelt vorhanden." % recipe.recipe_id)
			continue
		if not _item_database.has_item(recipe.output_item_id):
			push_error("Ausgabegegenstand '%s' fehlt im Katalog." % recipe.output_item_id)
			continue
		var ingredients_valid := true
		for ingredient_id in recipe.ingredient_item_ids:
			if not _item_database.has_item(ingredient_id):
				ingredients_valid = false
				push_error("Zutat '%s' des Rezepts '%s' fehlt im Katalog." % [ingredient_id, recipe.recipe_id])
		if ingredients_valid:
			_recipes_by_id[recipe.recipe_id] = recipe

func _add_to_storage(item_id: StringName, amount: int) -> int:
	return _add_to_slots(storage_slots, item_id, amount)

func _add_to_slots(slots: Array[InventorySlot], item_id: StringName, amount: int) -> int:
	var item := _item_database.get_item(item_id)
	if item == null:
		return amount
	var remaining := amount
	var stack_limit := item.get_stack_limit()
	for slot in slots:
		if slot.item_id != item_id or slot.amount >= stack_limit:
			continue
		var added := mini(remaining, stack_limit - slot.amount)
		slot.amount += added
		remaining -= added
		if remaining == 0:
			return 0
	for slot in slots:
		if not slot.is_empty():
			continue
		var added := mini(remaining, stack_limit)
		slot.set_stack(item_id, added)
		remaining -= added
		if remaining == 0:
			return 0
	return remaining

func _remove_from_slots(slots: Array[InventorySlot], item_id: StringName, amount: int) -> int:
	var remaining := amount
	for slot in slots:
		if slot.item_id != item_id:
			continue
		var removed := mini(remaining, slot.amount)
		slot.set_stack(item_id, slot.amount - removed)
		remaining -= removed
		if remaining == 0:
			return 0
	return remaining

func _duplicate_slots(slots: Array[InventorySlot]) -> Array[InventorySlot]:
	var duplicated_slots: Array[InventorySlot] = []
	for slot in slots:
		var duplicated_slot := InventorySlot.new()
		duplicated_slot.set_stack(slot.item_id, slot.amount)
		duplicated_slots.append(duplicated_slot)
	return duplicated_slots

func _rollback_inventory_transfers(transferred_materials: Dictionary) -> void:
	for item_id_value in transferred_materials:
		var item_id := item_id_value as StringName
		var amount := int(transferred_materials[item_id])
		_remove_from_slots(storage_slots, item_id, amount)
		_inventory_system.try_add_item(item_id, amount)

func _rebuild_reservations_from_queue() -> void:
	_reserved_amounts.clear()
	for entry in _queue:
		var recipe := get_recipe(StringName(entry.get("recipe_id", "")))
		var remaining_amount := maxi(int(entry.get("remaining_amount", 0)), 0)
		if recipe == null:
			continue
		var required_materials := _get_required_materials(recipe, remaining_amount)
		for item_id_value in required_materials:
			var item_id := item_id_value as StringName
			_reserved_amounts[item_id] = get_reserved_amount(item_id) + int(required_materials[item_id])

func _cancel_invalid_current_entry() -> void:
	_queue.pop_front()
	_progress_seconds = 0.0
	queue_changed.emit()
