class_name InventorySlotControl
extends Button

signal quantity_transfer_requested(container_id: StringName, slot_index: int)

var container_id: StringName
var slot_index: int
var inventory_system: InventorySystem
var item_database: ItemDatabase

func setup(new_inventory_system: InventorySystem, new_item_database: ItemDatabase, new_container_id: StringName, new_slot_index: int) -> void:
	inventory_system = new_inventory_system
	item_database = new_item_database
	container_id = new_container_id
	slot_index = new_slot_index
	custom_minimum_size = Vector2(64, 64)
	clip_text = true
	text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	focus_mode = Control.FOCUS_NONE
	update_slot()

func update_slot() -> void:
	if inventory_system == null:
		return
	var slot := inventory_system.get_slot(container_id, slot_index)
	if slot == null or slot.is_empty():
		text = str(slot_index + 1) if container_id == InventorySystem.ACTION_BAR_CONTAINER else ""
		icon = null
		tooltip_text = "Leerer Platz"
		return

	var item := item_database.get_item(slot.item_id)
	if item == null:
		return
	text = "%s\n%d" % [item.display_name, slot.amount]
	icon = item.icon
	tooltip_text = "%s\n%s\nMenge: %d" % [item.display_name, item.description, slot.amount]

func set_selected(is_selected: bool) -> void:
	button_pressed = is_selected

func _pressed() -> void:
	if container_id == InventorySystem.ACTION_BAR_CONTAINER:
		inventory_system.select_action_slot(slot_index)

func _gui_input(event: InputEvent) -> void:
	if not event is InputEventMouseButton or not event.pressed:
		return
	if event.button_index == MOUSE_BUTTON_LEFT and event.shift_pressed:
		inventory_system.quick_transfer(container_id, slot_index)
		accept_event()
	elif event.button_index == MOUSE_BUTTON_RIGHT and event.shift_pressed:
		inventory_system.split_half(container_id, slot_index)
		accept_event()
	elif event.button_index == MOUSE_BUTTON_RIGHT and event.ctrl_pressed:
		quantity_transfer_requested.emit(container_id, slot_index)
		accept_event()

func _get_drag_data(_at_position: Vector2) -> Variant:
	var slot := inventory_system.get_slot(container_id, slot_index)
	if slot == null or slot.is_empty():
		return null
	var preview := Button.new()
	preview.custom_minimum_size = Vector2(64, 64)
	preview.clip_text = true
	preview.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	preview.text = text
	preview.icon = icon
	preview.mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_drag_preview(preview)
	return {"container_id": container_id, "slot_index": slot_index}

func _can_drop_data(_at_position: Vector2, data: Variant) -> bool:
	return data is Dictionary and data.has("container_id") and data.has("slot_index")

func _drop_data(_at_position: Vector2, data: Variant) -> void:
	inventory_system.move_stack(data["container_id"] as StringName, data["slot_index"] as int, container_id, slot_index)
