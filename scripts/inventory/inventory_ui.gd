class_name InventoryUI
extends CanvasLayer

@onready var inventory_panel: PanelContainer = $Root/InventoryPanel
@onready var inventory_grid: GridContainer = $Root/InventoryPanel/Margin/VBox/InventoryScroll/InventoryGrid
@onready var action_bar_grid: GridContainer = $Root/ActionBar/Margin/ActionBarGrid
@onready var message_label: Label = $Root/MessageLabel
@onready var quantity_dialog: ConfirmationDialog = $QuantityDialog
@onready var quantity_spin_box: SpinBox = $QuantityDialog/QuantitySpinBox

var _inventory_system: InventorySystem
var _item_database: ItemDatabase
var _calendar: GameCalendar
var _inventory_slot_controls: Array[InventorySlotControl] = []
var _action_slot_controls: Array[InventorySlotControl] = []
var _quantity_source_container: StringName = &""
var _quantity_source_index: int = -1

func _ready() -> void:
	_inventory_system = get_tree().get_first_node_in_group(&"inventory_system") as InventorySystem
	_item_database = get_tree().get_first_node_in_group(&"item_database") as ItemDatabase
	_calendar = get_tree().get_first_node_in_group(&"game_calendar") as GameCalendar
	if _inventory_system == null or _item_database == null:
		push_error("Die Inventaroberfläche findet das Inventar oder die ItemDatabase nicht.")
		return

	_inventory_system.slots_changed.connect(_on_slots_changed)
	_inventory_system.capacity_changed.connect(_on_capacity_changed)
	_inventory_system.selected_action_slot_changed.connect(_on_selected_action_slot_changed)
	_inventory_system.inventory_full.connect(_show_message)
	_inventory_system.operation_rejected.connect(_show_message)
	quantity_dialog.confirmed.connect(_on_quantity_confirmed)
	_rebuild_inventory_grid()
	_build_action_bar()
	_update_all_slots()
	inventory_panel.visible = false
	message_label.visible = false

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.is_echo():
		return
	if event.is_action_pressed(&"inventory_toggle"):
		_set_inventory_open(not inventory_panel.visible)
		get_viewport().set_input_as_handled()
		return
	for slot_index in InventorySystem.ACTION_BAR_SLOTS:
		if event.is_action_pressed(&"action_slot_%d" % (slot_index + 1)):
			_inventory_system.select_action_slot(slot_index)
			get_viewport().set_input_as_handled()
			return

func is_inventory_open() -> bool:
	return inventory_panel.visible

func _set_inventory_open(is_open: bool) -> void:
	inventory_panel.visible = is_open
	if _calendar == null:
		return
	if is_open:
		_calendar.pause_time(GameCalendar.PAUSE_REASON_MENU)
	else:
		_calendar.resume_time(GameCalendar.PAUSE_REASON_MENU)

func _rebuild_inventory_grid() -> void:
	for child in inventory_grid.get_children():
		child.queue_free()
	_inventory_slot_controls.clear()
	for slot_index in _inventory_system.get_inventory_capacity():
		var slot_control := InventorySlotControl.new()
		slot_control.setup(_inventory_system, _item_database, InventorySystem.INVENTORY_CONTAINER, slot_index)
		slot_control.quantity_transfer_requested.connect(_open_quantity_dialog)
		inventory_grid.add_child(slot_control)
		_inventory_slot_controls.append(slot_control)

func _build_action_bar() -> void:
	for child in action_bar_grid.get_children():
		child.queue_free()
	_action_slot_controls.clear()
	for slot_index in InventorySystem.ACTION_BAR_SLOTS:
		var slot_control := InventorySlotControl.new()
		slot_control.toggle_mode = true
		slot_control.setup(_inventory_system, _item_database, InventorySystem.ACTION_BAR_CONTAINER, slot_index)
		slot_control.quantity_transfer_requested.connect(_open_quantity_dialog)
		action_bar_grid.add_child(slot_control)
		_action_slot_controls.append(slot_control)

func _update_all_slots() -> void:
	for slot_control in _inventory_slot_controls:
		slot_control.update_slot()
	for slot_control in _action_slot_controls:
		slot_control.update_slot()
	_on_selected_action_slot_changed(_inventory_system.selected_action_slot)

func _on_slots_changed(_container_id: StringName) -> void:
	_update_all_slots()

func _on_capacity_changed(_inventory_capacity: int, _purchased_upgrades: int) -> void:
	_rebuild_inventory_grid()
	_update_all_slots()

func _on_selected_action_slot_changed(slot_index: int) -> void:
	for index in _action_slot_controls.size():
		_action_slot_controls[index].set_selected(index == slot_index)

func _open_quantity_dialog(container_id: StringName, slot_index: int) -> void:
	var slot := _inventory_system.get_slot(container_id, slot_index)
	if slot == null or slot.is_empty():
		return
	_quantity_source_container = container_id
	_quantity_source_index = slot_index
	quantity_spin_box.min_value = 1
	if slot.amount < 2:
		_show_message("Dieser Stapel kann nicht weiter geteilt werden.")
		return
	quantity_spin_box.max_value = slot.amount - 1
	quantity_spin_box.value = 1
	quantity_dialog.popup_centered(Vector2i(420, 180))

func _on_quantity_confirmed() -> void:
	_inventory_system.split_amount(_quantity_source_container, _quantity_source_index, int(quantity_spin_box.value))

func _show_message(message: String) -> void:
	message_label.text = message
	message_label.visible = true
	await get_tree().create_timer(2.5).timeout
	if message_label.text == message:
		message_label.visible = false
