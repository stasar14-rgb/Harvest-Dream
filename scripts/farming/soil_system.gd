class_name SoilSystem
extends Node2D

signal soil_cell_changed(cell: Vector2i)
signal soil_cell_removed(cell: Vector2i)
signal soil_action_completed(tool: ToolData, affected_cells: int, energy_cost: float)
signal soil_action_rejected(message: String)

const ENERGY_STEP := 0.5

## Größe eines Bodenfeldes in Pixeln. Sie muss dem Raster der Karte entsprechen.
@export_range(1, 256, 1) var grid_size: int = 32
## Ursprung des Bodenrasters relativ zum Areal.
@export var grid_origin: Vector2 = Vector2.ZERO
## Rechteck aus Rasterkoordinaten, in dem Boden mit Werkzeugen bearbeitet werden darf.
@export var tillable_area: Rect2i = Rect2i(2, 2, 36, 18)
## Anzahl vollständiger Tage, nach denen unbepflanzter Ackerboden verschwindet.
@export_range(1, 99, 1) var unplanted_revert_days: int = 3
## Vorläufige Farbe für trockenen Ackerboden.
@export var dry_soil_color: Color = Color(0.42, 0.25, 0.12, 1.0)
## Vorläufige Farbe für bewässerten Ackerboden.
@export var watered_soil_color: Color = Color(0.22, 0.24, 0.18, 1.0)
## Sichtbare Trennlinie zwischen benachbarten Ackerfeldern.
@export var soil_border_color: Color = Color(0.16, 0.10, 0.05, 0.8)

var _soil_cells: Dictionary = {}
var _player_energy: PlayerEnergy
var _calendar: GameCalendar
var _tool_controller: ToolController

func _ready() -> void:
	_player_energy = get_tree().get_first_node_in_group(&"player_energy") as PlayerEnergy
	_calendar = get_tree().get_first_node_in_group(&"game_calendar") as GameCalendar

	if _player_energy == null:
		push_error("SoilSystem findet keine PlayerEnergy.")
		return
	if _calendar == null:
		push_error("SoilSystem findet keinen GameCalendar.")
		return

	_calendar.day_started.connect(_on_day_started)
	_connect_tool_controller.call_deferred()

func world_to_cell(world_position: Vector2) -> Vector2i:
	var local_position := to_local(world_position) - grid_origin
	return Vector2i(
		floori(local_position.x / float(grid_size)),
		floori(local_position.y / float(grid_size))
	)

func cell_to_world_center(cell: Vector2i) -> Vector2:
	var local_center := grid_origin + Vector2(cell) * float(grid_size)
	local_center += Vector2.ONE * float(grid_size) * 0.5
	return to_global(local_center)

func is_tillable_cell(cell: Vector2i) -> bool:
	return tillable_area.has_point(cell)

func has_tilled_soil(cell: Vector2i) -> bool:
	return _soil_cells.has(cell)

func is_watered(cell: Vector2i) -> bool:
	var state := _soil_cells.get(cell) as SoilCellState
	return state != null and state.watered

func set_cell_has_plant(cell: Vector2i, has_plant: bool) -> bool:
	var state := _soil_cells.get(cell) as SoilCellState
	if state == null:
		return false

	state.has_plant = has_plant
	if has_plant:
		state.days_without_plant = 0
	soil_cell_changed.emit(cell)
	return true

func get_soil_data() -> Array[Dictionary]:
	var data: Array[Dictionary] = []
	for cell_key in _soil_cells:
		var cell: Vector2i = cell_key
		var state := _soil_cells[cell] as SoilCellState
		if state != null:
			data.append(state.to_dictionary(cell))
	return data

func load_soil_data(data: Array[Dictionary]) -> void:
	_soil_cells.clear()
	for entry in data:
		var cell := Vector2i(int(entry.get("x", 0)), int(entry.get("y", 0)))
		if is_tillable_cell(cell):
			_soil_cells[cell] = SoilCellState.from_dictionary(entry)
	queue_redraw()

func _connect_tool_controller() -> void:
	_tool_controller = get_tree().get_first_node_in_group(&"tool_controller") as ToolController
	if _tool_controller == null:
		push_error("SoilSystem findet keinen ToolController.")
		return
	if not _tool_controller.tool_use_requested.is_connected(_on_tool_use_requested):
		_tool_controller.tool_use_requested.connect(_on_tool_use_requested)

func _on_tool_use_requested(
	tool: ToolData,
	target_positions: Array[Vector2],
	base_energy_cost: float
) -> void:
	if not _is_soil_tool(tool):
		return

	var valid_cells := _get_valid_target_cells(tool, target_positions)
	if valid_cells.is_empty():
		soil_action_rejected.emit("Keines der ausgewählten Felder kann mit diesem Werkzeug bearbeitet werden.")
		return

	var proportional_cost := base_energy_cost * float(valid_cells.size()) / float(target_positions.size())
	var rounded_cost := _round_to_energy_step(proportional_cost)
	if not _player_energy.can_afford(rounded_cost):
		soil_action_rejected.emit("Nicht genug Energie für diese Werkzeugaktion.")
		return

	_player_energy.consume_energy(rounded_cost)
	for cell in valid_cells:
		_apply_tool_to_cell(tool, cell)

	soil_action_completed.emit(tool, valid_cells.size(), rounded_cost)
	queue_redraw()

func _get_valid_target_cells(
	tool: ToolData,
	target_positions: Array[Vector2]
) -> Array[Vector2i]:
	var valid_cells: Array[Vector2i] = []
	for target_position in target_positions:
		var cell := world_to_cell(target_position)
		if valid_cells.has(cell):
			continue
		if _is_valid_for_tool(tool, cell):
			valid_cells.append(cell)
	return valid_cells

func _is_valid_for_tool(tool: ToolData, cell: Vector2i) -> bool:
	if not is_tillable_cell(cell):
		return false

	match tool.tool_type:
		ToolData.ToolType.HOE:
			return true
		ToolData.ToolType.WATERING_CAN:
			return has_tilled_soil(cell)
		ToolData.ToolType.SHOVEL:
			return has_tilled_soil(cell)
		_:
			return false

func _apply_tool_to_cell(tool: ToolData, cell: Vector2i) -> void:
	match tool.tool_type:
		ToolData.ToolType.HOE:
			if not has_tilled_soil(cell):
				_soil_cells[cell] = SoilCellState.new()
				soil_cell_changed.emit(cell)
		ToolData.ToolType.WATERING_CAN:
			var state := _soil_cells.get(cell) as SoilCellState
			if state != null:
				state.watered = true
				soil_cell_changed.emit(cell)
		ToolData.ToolType.SHOVEL:
			if _soil_cells.erase(cell):
				soil_cell_removed.emit(cell)

func _is_soil_tool(tool: ToolData) -> bool:
	return (
		tool.tool_type == ToolData.ToolType.HOE
		or tool.tool_type == ToolData.ToolType.WATERING_CAN
		or tool.tool_type == ToolData.ToolType.SHOVEL
	)

func _round_to_energy_step(value: float) -> float:
	return roundf(value / ENERGY_STEP) * ENERGY_STEP

func _on_day_started(
	_year: int,
	_month: int,
	_day: int,
	_wake_hour: int,
	_was_forced_sleep: bool
) -> void:
	var cells_to_remove: Array[Vector2i] = []

	for cell_key in _soil_cells:
		var cell: Vector2i = cell_key
		var state := _soil_cells[cell] as SoilCellState
		if state == null:
			continue

		state.watered = false
		if state.has_plant:
			state.days_without_plant = 0
		else:
			state.days_without_plant += 1
			if state.days_without_plant >= unplanted_revert_days:
				cells_to_remove.append(cell)

		soil_cell_changed.emit(cell)

	for cell in cells_to_remove:
		_soil_cells.erase(cell)
		soil_cell_removed.emit(cell)

	queue_redraw()

func _draw() -> void:
	var cell_size := Vector2(float(grid_size), float(grid_size))
	for cell_key in _soil_cells:
		var cell: Vector2i = cell_key
		var state := _soil_cells[cell] as SoilCellState
		if state == null:
			continue

		var position := grid_origin + Vector2(cell) * float(grid_size)
		var cell_rect := Rect2(position, cell_size)
		var fill_color := watered_soil_color if state.watered else dry_soil_color
		draw_rect(cell_rect, fill_color, true)
		draw_rect(cell_rect, soil_border_color, false, 1.0)
