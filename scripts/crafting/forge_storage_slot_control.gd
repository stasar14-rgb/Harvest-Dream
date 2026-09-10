class_name ForgeStorageSlotControl
extends Button

var slot_index: int = -1
var forge_system: ForgeSystem
var item_database: ItemDatabase

func setup(new_forge_system: ForgeSystem, new_item_database: ItemDatabase, new_slot_index: int) -> void:
	forge_system = new_forge_system
	item_database = new_item_database
	slot_index = new_slot_index
	custom_minimum_size = Vector2(92.0, 72.0)
	clip_text = true
	text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	focus_mode = Control.FOCUS_NONE
	update_slot()

func update_slot() -> void:
	if forge_system == null or item_database == null:
		return
	var slots := forge_system.get_storage_slots()
	if slot_index < 0 or slot_index >= slots.size():
		return
	var slot := slots[slot_index]
	if slot.is_empty():
		text = ""
		icon = null
		tooltip_text = "Leerer Platz im Schmiedelager"
		return
	var item := item_database.get_item(slot.item_id)
	if item == null:
		return
	var reserved_amount := mini(forge_system.get_reserved_amount(slot.item_id), slot.amount)
	text = "%s\n%d" % [item.display_name, slot.amount]
	icon = item.icon
	tooltip_text = "%s\nMenge: %d\nDavon für Aufträge reserviert: %d\nUmschalt + Linksklick: ins Inventar" % [
		item.display_name,
		slot.amount,
		reserved_amount,
	]

func _gui_input(event: InputEvent) -> void:
	if (
		event is InputEventMouseButton
		and event.pressed
		and event.button_index == MOUSE_BUTTON_LEFT
		and event.shift_pressed
	):
		forge_system.transfer_storage_slot_to_inventory(slot_index)
		accept_event()
