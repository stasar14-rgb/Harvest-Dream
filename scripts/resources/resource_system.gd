class_name ResourceSystem
extends Node2D

signal resource_hit(resource: HarvestableResource, tool: ToolData, current_hits: int, required_hits: int)
signal resource_depleted(resource: HarvestableResource, item_id: StringName, amount: int)
signal resource_respawned(resource: HarvestableResource)
signal resource_action_rejected(message: String)

## Größe eines Feldes im Raster der Spielwelt.
@export_range(1, 256, 1) var grid_size: int = 32
## Ursprung des Ressourcenrasters relativ zum Areal.
@export var grid_origin: Vector2 = Vector2.ZERO

var _resources_by_cell: Dictionary = {}
var _resources_by_id: Dictionary = {}
var _tool_controller: ToolController
var _player_energy: PlayerEnergy
var _inventory_system: InventorySystem
var _item_database: ItemDatabase
var _calendar: GameCalendar
var _inventory_ui: InventoryUI

func _ready() -> void:
	_tool_controller = get_tree().get_first_node_in_group(&"tool_controller") as ToolController
	_player_energy = get_tree().get_first_node_in_group(&"player_energy") as PlayerEnergy
	_inventory_system = get_tree().get_first_node_in_group(&"inventory_system") as InventorySystem
	_item_database = get_tree().get_first_node_in_group(&"item_database") as ItemDatabase
	_calendar = get_tree().get_first_node_in_group(&"game_calendar") as GameCalendar
	_inventory_ui = get_tree().get_first_node_in_group(&"inventory_ui") as InventoryUI

	if (
		_tool_controller == null
		or _player_energy == null
		or _inventory_system == null
		or _item_database == null
		or _calendar == null
	):
		push_error("ResourceSystem findet Werkzeug-, Energie-, Inventar- oder Kalendersystem nicht.")
		return

	_index_resources()
	_tool_controller.tool_use_requested.connect(_on_tool_use_requested)
	_calendar.day_started.connect(_on_day_started)

func world_to_cell(world_position: Vector2) -> Vector2i:
	var local_position := to_local(world_position) - grid_origin
	return Vector2i(
		floori(local_position.x / float(grid_size)),
		floori(local_position.y / float(grid_size))
	)

func get_resource_at_cell(cell: Vector2i) -> HarvestableResource:
	return _resources_by_cell.get(cell) as HarvestableResource

func get_resource_state_data() -> Array[Dictionary]:
	var data: Array[Dictionary] = []
	for resource_value in _resources_by_id.values():
		var resource := resource_value as HarvestableResource
		if resource != null:
			data.append(resource.get_state_data())
	return data

func load_resource_state_data(data: Array[Dictionary]) -> void:
	for entry in data:
		var instance_id := StringName(entry.get("resource_instance_id", ""))
		var resource := _resources_by_id.get(instance_id) as HarvestableResource
		if resource == null:
			push_error("Gespeichertes Ressourcenvorkommen '%s' wurde im Areal nicht gefunden." % instance_id)
			continue
		resource.load_state_data(entry)

func _index_resources() -> void:
	_resources_by_cell.clear()
	_resources_by_id.clear()
	for child in get_children():
		var resource := child as HarvestableResource
		if resource == null or resource.resource_data == null:
			continue
		if resource.resource_instance_id == &"" or not resource.resource_data.is_valid_definition():
			continue
		if not _item_database.has_item(resource.resource_data.drop_item_id):
			push_error("Beutegegenstand '%s' der Ressource '%s' fehlt im Katalog." % [resource.resource_data.drop_item_id, resource.resource_instance_id])
			continue
		var cell := world_to_cell(resource.global_position)
		if _resources_by_cell.has(cell):
			push_error("Mehrere Ressourcenvorkommen liegen auf Rasterfeld %s." % cell)
			continue
		if _resources_by_id.has(resource.resource_instance_id):
			push_error("Ressourcen-Instanz-ID '%s' ist doppelt vorhanden." % resource.resource_instance_id)
			continue
		_resources_by_cell[cell] = resource
		_resources_by_id[resource.resource_instance_id] = resource
		resource.respawned.connect(_on_resource_respawned)

func _on_tool_use_requested(
	tool: ToolData,
	target_positions: Array[Vector2],
	base_energy_cost: float
) -> void:
	if tool.tool_type != ToolData.ToolType.AXE and tool.tool_type != ToolData.ToolType.PICKAXE:
		return
	if target_positions.is_empty():
		_reject_action("Vor dem Spieler befindet sich keine erreichbare Ressource.")
		return

	var target_cell := world_to_cell(target_positions[0])
	var resource := get_resource_at_cell(target_cell)
	if resource == null or resource.is_depleted:
		_reject_action("Vor dem Spieler befindet sich keine erreichbare Ressource.")
		return
	if not resource.can_be_hit_with(tool):
		_reject_action("Für diese Ressource wird ein anderes Werkzeug benötigt.")
		return
	if not _player_energy.can_afford(base_energy_cost):
		_reject_action("Nicht genug Energie für diesen Schlag.")
		return

	if resource.will_deplete_with(tool):
		var data := resource.resource_data
		if not _inventory_system.can_add_item(data.drop_item_id, data.drop_amount):
			_reject_action("Inventar voll – die Ressource wurde nicht abgebaut.")
			return

	_player_energy.consume_energy(base_energy_cost)
	resource.apply_hit(tool)
	resource_hit.emit(
		resource,
		tool,
		resource.current_hits,
		resource.resource_data.get_required_hits(tool)
	)

	if resource.is_depleted:
		_inventory_system.try_add_item(
			resource.resource_data.drop_item_id,
			resource.resource_data.drop_amount
		)
		resource_depleted.emit(
			resource,
			resource.resource_data.drop_item_id,
			resource.resource_data.drop_amount
		)

func _on_day_started(
	_year: int,
	_month: int,
	_day: int,
	_wake_hour: int,
	_was_forced_sleep: bool
) -> void:
	for resource_value in _resources_by_id.values():
		var resource := resource_value as HarvestableResource
		if resource != null:
			resource.advance_respawn_day()

func _on_resource_respawned(resource: HarvestableResource) -> void:
	resource_respawned.emit(resource)

func _reject_action(message: String) -> void:
	resource_action_rejected.emit(message)
	if _inventory_ui != null:
		_inventory_ui.show_message(message)
