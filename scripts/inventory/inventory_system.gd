class_name InventorySystem
extends Node

signal slots_changed(container_id: StringName)
signal capacity_changed(inventory_capacity: int, purchased_upgrades: int)
signal selected_action_slot_changed(slot_index: int)
signal action_slot_requested(slot_index: int, item_id: StringName)
signal inventory_full(message: String)
signal operation_rejected(message: String)

const INVENTORY_CONTAINER: StringName = &"inventory"
const ACTION_BAR_CONTAINER: StringName = &"action_bar"
const STARTING_INVENTORY_SLOTS := 16
const SLOTS_PER_UPGRADE := 16
const MAX_BAG_UPGRADES := 2
const ACTION_BAR_SLOTS := 10

## Fügt beim Start einige Kataloggegenstände ein, damit die Inventarbedienung auf der Testfläche geprüft werden kann.
@export var add_debug_starting_items: bool = true
## Goldkosten der beiden Taschenerweiterungen. Der Wert -1 bedeutet, dass der Preis noch nicht festgelegt wurde.
@export var bag_upgrade_costs: Array[int] = [-1, -1]

var inventory_slots: Array[InventorySlot] = []
var action_bar_slots: Array[InventorySlot] = []
## Anzahl bereits freigeschalteter Taschenerweiterungen. Für Tests sind Werte von 0 bis 2 erlaubt.
@export_range(0, MAX_BAG_UPGRADES, 1) var purchased_bag_upgrades: int = 0
var selected_action_slot: int = 0

var _item_database: ItemDatabase

func _ready() -> void:
	_item_database = get_tree().get_first_node_in_group(&"item_database") as ItemDatabase
	if _item_database == null:
		push_error("Das Inventarsystem findet keine ItemDatabase.")
		return

	purchased_bag_upgrades = clampi(purchased_bag_upgrades, 0, MAX_BAG_UPGRADES)
	_resize_slot_array(inventory_slots, get_inventory_capacity())
	_resize_slot_array(action_bar_slots, ACTION_BAR_SLOTS)

	if add_debug_starting_items:
		try_add_item(&"wood", 50)
		try_add_item(&"ore", 20)
		try_add_item(&"berries", 10)

func get_inventory_capacity() -> int:
	return STARTING_INVENTORY_SLOTS + purchased_bag_upgrades * SLOTS_PER_UPGRADE

func get_maximum_inventory_capacity() -> int:
	return STARTING_INVENTORY_SLOTS + MAX_BAG_UPGRADES * SLOTS_PER_UPGRADE

func get_total_available_slots() -> int:
	return get_inventory_capacity() + ACTION_BAR_SLOTS

func get_next_bag_upgrade_number() -> int:
	return purchased_bag_upgrades + 1 if purchased_bag_upgrades < MAX_BAG_UPGRADES else 0

func unlock_next_bag_upgrade() -> bool:
	if purchased_bag_upgrades >= MAX_BAG_UPGRADES:
		operation_rejected.emit("Alle Taschenerweiterungen wurden bereits gekauft.")
		return false

	purchased_bag_upgrades += 1
	_resize_slot_array(inventory_slots, get_inventory_capacity())
	capacity_changed.emit(get_inventory_capacity(), purchased_bag_upgrades)
	slots_changed.emit(INVENTORY_CONTAINER)
	return true

func can_add_item(item_id: StringName, amount: int) -> bool:
	if not _is_valid_item_amount(item_id, amount):
		return false
	return get_free_capacity_for(item_id) >= amount

func try_add_item(item_id: StringName, amount: int) -> bool:
	if not _is_valid_item_amount(item_id, amount):
		return false
	if not can_add_item(item_id, amount):
		inventory_full.emit("Inventar voll – der Gegenstand wurde nicht aufgenommen.")
		return false

	var remaining := _add_to_container(inventory_slots, item_id, amount)
	if remaining > 0:
		remaining = _add_to_container(action_bar_slots, item_id, remaining)
	slots_changed.emit(INVENTORY_CONTAINER)
	slots_changed.emit(ACTION_BAR_CONTAINER)
	return remaining == 0

func remove_item(item_id: StringName, amount: int) -> bool:
	if amount <= 0 or get_item_amount(item_id) < amount:
		return false

	var remaining := _remove_from_container(inventory_slots, item_id, amount)
	if remaining > 0:
		remaining = _remove_from_container(action_bar_slots, item_id, remaining)
	slots_changed.emit(INVENTORY_CONTAINER)
	slots_changed.emit(ACTION_BAR_CONTAINER)
	return remaining == 0

func get_item_amount(item_id: StringName) -> int:
	var total := 0
	for slot in inventory_slots:
		if slot.item_id == item_id:
			total += slot.amount
	for slot in action_bar_slots:
		if slot.item_id == item_id:
			total += slot.amount
	return total

func get_free_capacity_for(item_id: StringName) -> int:
	var item := _item_database.get_item(item_id) if _item_database != null else null
	if item == null:
		return 0
	return _get_container_free_capacity(inventory_slots, item_id, item.get_stack_limit()) \
		+ _get_container_free_capacity(action_bar_slots, item_id, item.get_stack_limit())

func get_slots(container_id: StringName) -> Array[InventorySlot]:
	if container_id == INVENTORY_CONTAINER:
		return inventory_slots
	if container_id == ACTION_BAR_CONTAINER:
		return action_bar_slots
	return []

func get_slot(container_id: StringName, slot_index: int) -> InventorySlot:
	var slots := get_slots(container_id)
	if slot_index < 0 or slot_index >= slots.size():
		return null
	return slots[slot_index]

func move_stack(from_container: StringName, from_index: int, to_container: StringName, to_index: int, amount: int = -1) -> bool:
	var source := get_slot(from_container, from_index)
	var target := get_slot(to_container, to_index)
	if source == null or target == null or source.is_empty():
		return false
	if from_container == to_container and from_index == to_index:
		return false

	var move_amount := source.amount if amount < 0 else min(amount, source.amount)
	if move_amount <= 0:
		return false

	if target.is_empty():
		target.set_stack(source.item_id, move_amount)
		source.set_stack(source.item_id, source.amount - move_amount)
	elif target.item_id == source.item_id:
		var item := _item_database.get_item(source.item_id)
		if item == null:
			return false
		var transferable := min(move_amount, item.get_stack_limit() - target.amount)
		if transferable <= 0:
			return false
		target.amount += transferable
		source.set_stack(source.item_id, source.amount - transferable)
	else:
		if move_amount != source.amount:
			return false
		var source_item_id := source.item_id
		var source_amount := source.amount
		source.set_stack(target.item_id, target.amount)
		target.set_stack(source_item_id, source_amount)

	slots_changed.emit(from_container)
	if to_container != from_container:
		slots_changed.emit(to_container)
	return true

func quick_transfer(from_container: StringName, from_index: int) -> bool:
	var target_container := ACTION_BAR_CONTAINER if from_container == INVENTORY_CONTAINER else INVENTORY_CONTAINER
	var source := get_slot(from_container, from_index)
	if source == null or source.is_empty():
		return false
	var target_slots := get_slots(target_container)
	var item := _item_database.get_item(source.item_id)
	if item == null:
		return false
	if _get_container_free_capacity(target_slots, source.item_id, item.get_stack_limit()) < source.amount:
		operation_rejected.emit("Im Zielbereich ist nicht genug Platz.")
		return false

	_add_to_container(target_slots, source.item_id, source.amount)
	source.clear()
	slots_changed.emit(from_container)
	slots_changed.emit(target_container)
	return true

func split_half(from_container: StringName, from_index: int) -> bool:
	var source := get_slot(from_container, from_index)
	if source == null or source.amount < 2:
		return false
	return split_amount(from_container, from_index, ceili(source.amount / 2.0))

func split_amount(from_container: StringName, from_index: int, amount: int) -> bool:
	var source := get_slot(from_container, from_index)
	if source == null or source.is_empty() or amount <= 0 or amount >= source.amount:
		return false
	var target_slots := get_slots(from_container)
	var empty_slot := _find_first_empty_slot(target_slots, from_index)
	if empty_slot == null:
		operation_rejected.emit("Zum Teilen wird ein leerer Platz im selben Bereich benötigt.")
		return false
	empty_slot.set_stack(source.item_id, amount)
	source.set_stack(source.item_id, source.amount - amount)
	slots_changed.emit(from_container)
	return true

func get_bag_upgrade_cost(upgrade_number: int) -> int:
	if upgrade_number < 1 or upgrade_number > bag_upgrade_costs.size():
		return -1
	return bag_upgrade_costs[upgrade_number - 1]

func select_action_slot(slot_index: int) -> bool:
	if slot_index < 0 or slot_index >= ACTION_BAR_SLOTS:
		return false
	selected_action_slot = slot_index
	selected_action_slot_changed.emit(selected_action_slot)
	return true

func request_selected_action_slot() -> void:
	var slot := action_bar_slots[selected_action_slot]
	action_slot_requested.emit(selected_action_slot, slot.item_id if not slot.is_empty() else &"")

func _is_valid_item_amount(item_id: StringName, amount: int) -> bool:
	if amount <= 0:
		return false
	if _item_database == null or not _item_database.has_item(item_id):
		push_error("Der Gegenstand '%s' ist nicht im Katalog registriert." % item_id)
		return false
	return true

func _resize_slot_array(slots: Array[InventorySlot], new_size: int) -> void:
	while slots.size() < new_size:
		slots.append(InventorySlot.new())

func _get_container_free_capacity(slots: Array[InventorySlot], item_id: StringName, stack_limit: int) -> int:
	var free_capacity := 0
	for slot in slots:
		if slot.is_empty():
			free_capacity += stack_limit
		elif slot.item_id == item_id:
			free_capacity += max(stack_limit - slot.amount, 0)
	return free_capacity

func _add_to_container(slots: Array[InventorySlot], item_id: StringName, amount: int) -> int:
	var item := _item_database.get_item(item_id)
	if item == null:
		return amount
	var remaining := amount
	var stack_limit := item.get_stack_limit()

	for slot in slots:
		if slot.item_id != item_id or slot.amount >= stack_limit:
			continue
		var added := min(remaining, stack_limit - slot.amount)
		slot.amount += added
		remaining -= added
		if remaining == 0:
			return 0

	for slot in slots:
		if not slot.is_empty():
			continue
		var added := min(remaining, stack_limit)
		slot.set_stack(item_id, added)
		remaining -= added
		if remaining == 0:
			return 0
	return remaining

func _remove_from_container(slots: Array[InventorySlot], item_id: StringName, amount: int) -> int:
	var remaining := amount
	for slot in slots:
		if slot.item_id != item_id:
			continue
		var removed := min(remaining, slot.amount)
		slot.set_stack(item_id, slot.amount - removed)
		remaining -= removed
		if remaining == 0:
			return 0
	return remaining

func _find_first_empty_slot(slots: Array[InventorySlot], excluded_index: int = -1) -> InventorySlot:
	for index in slots.size():
		if index != excluded_index and slots[index].is_empty():
			return slots[index]
	return null
