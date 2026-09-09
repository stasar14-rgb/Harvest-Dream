class_name ToolController
extends Node2D

signal active_tool_changed(tool: ToolData)
signal charge_level_changed(charge_level: int, field_count: int)
signal tool_use_requested(tool: ToolData, target_positions: Array[Vector2], base_energy_cost: float)

## Größe eines Feldes im Raster der Spielwelt.
@export_range(1, 256, 1) var grid_size: int = 32
## Verschiebt den Mittelpunkt des Spielerfeldes relativ zum Ursprung der Spielerfigur.
@export var player_grid_center_offset: Vector2 = Vector2(0.0, 16.0)
## Ursprung des globalen 32×32-Rasters. Er muss zum Raster des aktuellen Areals passen.
@export var grid_origin: Vector2 = Vector2.ZERO
## Füllfarbe der Zielfelder. Die Farbe ist nur eine vorläufige Testdarstellung.
@export var target_fill_color: Color = Color(1.0, 0.85, 0.15, 0.22)
## Rahmenfarbe der Zielfelder. Die Farbe ist nur eine vorläufige Testdarstellung.
@export var target_border_color: Color = Color(1.0, 0.85, 0.15, 0.95)
## Breite des sichtbaren Rahmens um jedes Zielfeld.
@export_range(1.0, 8.0, 0.5) var target_border_width: float = 2.0

var active_tool: ToolData
var _inventory_system: InventorySystem
var _item_database: ItemDatabase
var _inventory_ui: InventoryUI
var _player: PlayerMovement
var _tool_input_active := false
var _charge_elapsed := 0.0
var _current_charge_level := 0
var _last_facing_direction := Vector2i.DOWN

func _ready() -> void:
	_player = get_parent() as PlayerMovement
	_inventory_system = get_tree().get_first_node_in_group(&"inventory_system") as InventorySystem
	_item_database = get_tree().get_first_node_in_group(&"item_database") as ItemDatabase

	if _player == null:
		push_error("ToolController muss ein direktes Kind des Spielers sein.")
		return
	if _inventory_system == null or _item_database == null:
		push_error("ToolController findet das Inventar oder die ItemDatabase nicht.")
		return

	_inventory_system.selected_action_slot_changed.connect(_on_selected_action_slot_changed)
	_inventory_system.slots_changed.connect(_on_slots_changed)
	_last_facing_direction = _player.facing_direction
	_refresh_active_tool()

func _process(delta: float) -> void:
	if _shows_target_marker():
		queue_redraw()

	if _player != null and _last_facing_direction != _player.facing_direction:
		_last_facing_direction = _player.facing_direction
		queue_redraw()

	if not _tool_input_active or active_tool == null or not active_tool.uses_charge:
		return

	_charge_elapsed += delta
	var next_charge_level := active_tool.get_charge_level(_charge_elapsed)
	if next_charge_level == _current_charge_level:
		return

	_current_charge_level = next_charge_level
	charge_level_changed.emit(
		_current_charge_level,
		active_tool.get_charge_area_size(_current_charge_level)
	)
	queue_redraw()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"use_tool"):
		if _is_input_blocked() or active_tool == null:
			return
		_begin_tool_input()
		get_viewport().set_input_as_handled()
		return

	if event.is_action_released(&"use_tool") and _tool_input_active:
		_finish_tool_input()
		get_viewport().set_input_as_handled()

func get_target_world_positions() -> Array[Vector2]:
	var positions: Array[Vector2] = []
	if active_tool == null or _player == null:
		return positions

	var player_cell_center := _get_player_cell_center_world()
	for offset in _get_target_offsets():
		positions.append(player_cell_center + Vector2(offset) * float(grid_size))

	return positions

func _get_player_cell_center_world() -> Vector2:
	var player_grid_position := _player.global_position + player_grid_center_offset - grid_origin
	var player_cell := Vector2i(
		floori(player_grid_position.x / float(grid_size)),
		floori(player_grid_position.y / float(grid_size))
	)
	return (
		grid_origin
		+ Vector2(player_cell) * float(grid_size)
		+ Vector2.ONE * float(grid_size) * 0.5
	)

func _begin_tool_input() -> void:
	_tool_input_active = true
	_charge_elapsed = 0.0
	_current_charge_level = 0
	charge_level_changed.emit(0, active_tool.get_charge_area_size(0))
	queue_redraw()

func _finish_tool_input() -> void:
	var target_positions := get_target_world_positions()
	var energy_cost := active_tool.get_energy_cost(_current_charge_level)
	tool_use_requested.emit(active_tool, target_positions, energy_cost)
	_cancel_tool_input()

func _cancel_tool_input() -> void:
	_tool_input_active = false
	_charge_elapsed = 0.0
	_current_charge_level = 0
	queue_redraw()

func _refresh_active_tool() -> void:
	if _inventory_system == null or _item_database == null:
		return

	var slot := _inventory_system.get_slot(
		InventorySystem.ACTION_BAR_CONTAINER,
		_inventory_system.selected_action_slot
	)
	var next_tool: ToolData = null
	if slot != null and not slot.is_empty():
		next_tool = _item_database.get_item(slot.item_id) as ToolData

	if active_tool == next_tool:
		return

	_cancel_tool_input()
	active_tool = next_tool
	active_tool_changed.emit(active_tool)
	queue_redraw()

func _on_selected_action_slot_changed(_slot_index: int) -> void:
	_refresh_active_tool()

func _on_slots_changed(container_id: StringName) -> void:
	if container_id == InventorySystem.ACTION_BAR_CONTAINER:
		_refresh_active_tool()

func _is_input_blocked() -> bool:
	if _inventory_ui == null:
		_inventory_ui = get_tree().get_first_node_in_group(&"inventory_ui") as InventoryUI
	return _inventory_ui != null and _inventory_ui.is_inventory_open()

func _shows_target_marker() -> bool:
	if active_tool == null:
		return false
	return (
		active_tool.tool_type == ToolData.ToolType.HOE
		or active_tool.tool_type == ToolData.ToolType.WATERING_CAN
		or active_tool.tool_type == ToolData.ToolType.SHOVEL
	)

func _get_target_offsets() -> Array[Vector2i]:
	var offsets: Array[Vector2i] = []
	if not _shows_target_marker() or _player == null:
		return offsets

	var forward := _player.facing_direction
	var right := Vector2i(-forward.y, forward.x)
	var depth := 1
	var half_width := 0

	if active_tool.tool_type != ToolData.ToolType.SHOVEL:
		match _current_charge_level:
			1:
				half_width = 1
			2:
				half_width = 1
				depth = 2
			3:
				half_width = 1
				depth = 3

	for forward_step in range(1, depth + 1):
		for lateral_step in range(-half_width, half_width + 1):
			offsets.append(forward * forward_step + right * lateral_step)

	return offsets

func _draw() -> void:
	if not _shows_target_marker():
		return

	var cell_size := Vector2(float(grid_size), float(grid_size))
	var half_cell := cell_size * 0.5
	for world_position in get_target_world_positions():
		var center := to_local(world_position)
		var cell_rect := Rect2(center - half_cell, cell_size)
		draw_rect(cell_rect, target_fill_color, true)
		draw_rect(cell_rect, target_border_color, false, target_border_width)
