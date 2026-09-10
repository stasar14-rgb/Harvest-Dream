class_name FarmingController
extends Node2D

## Verschiebt den Mittelpunkt des Spielerfeldes relativ zum Ursprung der Spielerfigur.
@export var player_grid_center_offset: Vector2 = Vector2(0.0, 25.0)
## Füllfarbe des Zielfeldes, wenn Saatgut in der Aktionsleiste ausgewählt ist.
@export var sow_target_fill_color: Color = Color(0.35, 0.90, 0.30, 0.22)
## Rahmenfarbe des Zielfeldes, wenn Saatgut in der Aktionsleiste ausgewählt ist.
@export var sow_target_border_color: Color = Color(0.35, 0.90, 0.30, 0.95)
## Breite des sichtbaren Rahmens um das Saatgut-Zielfeld.
@export_range(1.0, 8.0, 0.5) var target_border_width: float = 2.0

var _player: PlayerMovement
var _inventory_system: InventorySystem
var _item_database: ItemDatabase
var _inventory_ui: InventoryUI
var _interactor: PlayerInteractor
var _connected_plant_system: PlantSystem

func _ready() -> void:
	_player = get_parent() as PlayerMovement
	_inventory_system = get_tree().get_first_node_in_group(&"inventory_system") as InventorySystem
	_item_database = get_tree().get_first_node_in_group(&"item_database") as ItemDatabase
	_interactor = get_node_or_null(^"../Interactor") as PlayerInteractor

	if _player == null:
		push_error("FarmingController muss ein direktes Kind des Spielers sein.")
		return
	if _inventory_system == null or _item_database == null:
		push_error("FarmingController findet das Inventar oder die ItemDatabase nicht.")
		return

	_inventory_system.selected_action_slot_changed.connect(_on_action_bar_changed)
	_inventory_system.slots_changed.connect(_on_inventory_slots_changed)

func _process(_delta: float) -> void:
	if _get_active_seed_data() != null:
		queue_redraw()

func _unhandled_input(event: InputEvent) -> void:
	if _is_input_blocked():
		return

	if event.is_action_pressed(&"use_tool"):
		var seed_data := _get_active_seed_data()
		if seed_data == null:
			return
		var plant_system := _get_plant_system()
		if plant_system == null:
			return
		var plant := plant_system.get_plant_for_seed(seed_data.item_id)
		if plant == null:
			return
		plant_system.try_sow(
			_get_target_cell(plant_system),
			plant,
			_inventory_system.selected_action_slot
		)
		get_viewport().set_input_as_handled()
		return

	if event.is_action_pressed(&"interact"):
		if _interactor != null and _interactor.has_focused_interactable():
			return
		var plant_system := _get_plant_system()
		if plant_system == null:
			return
		var target_cell := _get_target_cell(plant_system)
		if not plant_system.has_plant(target_cell):
			return
		plant_system.try_harvest(target_cell)
		get_viewport().set_input_as_handled()

func _get_active_seed_data() -> ItemData:
	if _inventory_system == null or _item_database == null:
		return null
	var slot := _inventory_system.get_slot(
		InventorySystem.ACTION_BAR_CONTAINER,
		_inventory_system.selected_action_slot
	)
	if slot == null or slot.is_empty():
		return null
	var item := _item_database.get_item(slot.item_id)
	if item == null or item.category != ItemData.Category.SEED:
		return null
	return item

func _get_plant_system() -> PlantSystem:
	var plant_system := get_tree().get_first_node_in_group(&"plant_system") as PlantSystem
	if plant_system == _connected_plant_system:
		return plant_system
	if is_instance_valid(_connected_plant_system):
		if _connected_plant_system.plant_action_rejected.is_connected(_on_plant_action_rejected):
			_connected_plant_system.plant_action_rejected.disconnect(_on_plant_action_rejected)
	_connected_plant_system = plant_system
	if _connected_plant_system != null:
		_connected_plant_system.plant_action_rejected.connect(_on_plant_action_rejected)
	return plant_system

func _get_target_cell(plant_system: PlantSystem) -> Vector2i:
	var player_cell := plant_system.get_soil_system().world_to_cell(
		_player.global_position + player_grid_center_offset
	)
	return player_cell + _player.facing_direction

func _is_input_blocked() -> bool:
	if _inventory_ui == null:
		_inventory_ui = get_tree().get_first_node_in_group(&"inventory_ui") as InventoryUI
	return _inventory_ui != null and _inventory_ui.is_inventory_open()

func _on_action_bar_changed(_slot_index: int) -> void:
	queue_redraw()

func _on_inventory_slots_changed(container_id: StringName) -> void:
	if container_id == InventorySystem.ACTION_BAR_CONTAINER:
		queue_redraw()

func _on_plant_action_rejected(message: String) -> void:
	if _inventory_ui == null:
		_inventory_ui = get_tree().get_first_node_in_group(&"inventory_ui") as InventoryUI
	if _inventory_ui != null:
		_inventory_ui.show_message(message)

func _draw() -> void:
	if _get_active_seed_data() == null:
		return
	var plant_system := _get_plant_system()
	if plant_system == null:
		return

	var soil_system := plant_system.get_soil_system()
	var center := to_local(soil_system.cell_to_world_center(_get_target_cell(plant_system)))
	var cell_size := Vector2.ONE * float(soil_system.grid_size)
	var cell_rect := Rect2(center - cell_size * 0.5, cell_size)
	draw_rect(cell_rect, sow_target_fill_color, true)
	draw_rect(cell_rect, sow_target_border_color, false, target_border_width)
