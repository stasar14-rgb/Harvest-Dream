class_name PlantSystem
extends Node2D

signal plant_sown(cell: Vector2i, plant: PlantData)
signal plant_changed(cell: Vector2i)
signal plant_spoiled(cell: Vector2i, plant: PlantData)
signal plant_harvested(cell: Vector2i, plant: PlantData, amount: int)
signal plant_removed(cell: Vector2i)
signal plant_action_rejected(message: String)

## Boden-System desselben Areals, auf dessen Ackerfeldern Pflanzen wachsen.
@export var soil_system_path: NodePath = ^"../SoilSystem"
## In diesem Areal verfügbare Pflanzendefinitionen. Konkrete Pflanzenarten werden später eingetragen.
@export var available_plants: Array[PlantData] = []
## Anzahl aufeinanderfolgender trockener Tage, nach denen eine Pflanze verdirbt.
@export_range(1, 99, 1) var dry_days_until_spoiled: int = 3
## Vorläufige Farbe wachsender Pflanzen, solange noch keine Wachstumsgrafiken eingetragen sind.
@export var growing_placeholder_color: Color = Color(0.30, 0.72, 0.24, 1.0)
## Vorläufige Farbe erntereifer Pflanzen, solange noch keine Wachstumsgrafiken eingetragen sind.
@export var ready_placeholder_color: Color = Color(0.90, 0.72, 0.18, 1.0)
## Vorläufige Farbe verdorbener Pflanzen, solange noch keine Grafik eingetragen ist.
@export var spoiled_placeholder_color: Color = Color(0.36, 0.34, 0.32, 1.0)

var _plants: Dictionary = {}
var _plants_by_id: Dictionary = {}
var _soil_system: SoilSystem
var _inventory_system: InventorySystem
var _item_database: ItemDatabase
var _season_system: SeasonSystem

func _ready() -> void:
	_soil_system = get_node_or_null(soil_system_path) as SoilSystem
	_inventory_system = get_tree().get_first_node_in_group(&"inventory_system") as InventorySystem
	_item_database = get_tree().get_first_node_in_group(&"item_database") as ItemDatabase
	_season_system = get_tree().get_first_node_in_group(&"season_system") as SeasonSystem

	if _soil_system == null:
		push_error("PlantSystem findet das zugehörige SoilSystem nicht.")
		return
	if _inventory_system == null or _item_database == null or _season_system == null:
		push_error("PlantSystem findet Inventar, ItemDatabase oder SeasonSystem nicht.")
		return

	_rebuild_plant_index()
	_soil_system.previous_day_soil_state_ready.connect(_on_previous_day_soil_state_ready)
	_soil_system.soil_cell_removed.connect(_on_soil_cell_removed)

func has_plant(cell: Vector2i) -> bool:
	return _plants.has(cell)

func get_plant_state(cell: Vector2i) -> PlantState:
	return _plants.get(cell) as PlantState

func can_sow(cell: Vector2i, plant: PlantData) -> bool:
	if plant == null or not plant.is_valid_definition():
		return false
	if not _soil_system.has_tilled_soil(cell) or has_plant(cell):
		return false
	if not plant.is_available_in_season(_season_system.current_season):
		return false
	return _inventory_system.get_item_amount(plant.seed_item_id) > 0

func try_sow(cell: Vector2i, plant: PlantData) -> bool:
	if not can_sow(cell, plant):
		plant_action_rejected.emit("Dieses Saatgut kann auf dem ausgewählten Feld nicht ausgesät werden.")
		return false
	if not _inventory_system.remove_item(plant.seed_item_id, 1):
		plant_action_rejected.emit("Das benötigte Saatgut konnte nicht verbraucht werden.")
		return false

	var state := PlantState.new()
	state.plant_data = plant
	_plants[cell] = state
	_soil_system.set_cell_has_plant(cell, true)
	plant_sown.emit(cell, plant)
	queue_redraw()
	return true

func try_harvest(cell: Vector2i) -> bool:
	var state := get_plant_state(cell)
	if state == null or not state.is_ready_for_harvest():
		plant_action_rejected.emit("Auf diesem Feld ist keine erntereife Pflanze vorhanden.")
		return false

	var plant := state.plant_data
	if not _inventory_system.can_add_item(plant.harvest_item_id, plant.harvest_amount):
		plant_action_rejected.emit("Inventar voll – die Pflanze wurde nicht geerntet.")
		return false
	if not _inventory_system.try_add_item(plant.harvest_item_id, plant.harvest_amount):
		plant_action_rejected.emit("Die Ernte konnte nicht ins Inventar gelegt werden.")
		return false

	_remove_plant(cell)
	plant_harvested.emit(cell, plant, plant.harvest_amount)
	return true

func remove_plant(cell: Vector2i) -> bool:
	if not has_plant(cell):
		return false
	_remove_plant(cell)
	return true

func get_plant_data() -> Array[Dictionary]:
	var data: Array[Dictionary] = []
	for cell_key in _plants:
		var cell: Vector2i = cell_key
		var state := _plants[cell] as PlantState
		if state != null:
			data.append(state.to_dictionary(cell))
	return data

func load_plant_data(data: Array[Dictionary]) -> void:
	for cell_key in _plants:
		_soil_system.set_cell_has_plant(cell_key as Vector2i, false)
	_plants.clear()

	for entry in data:
		var plant_id := StringName(entry.get("plant_id", ""))
		var definition := _plants_by_id.get(plant_id) as PlantData
		if definition == null:
			push_error("Gespeicherte Pflanzen-ID '%s' ist in diesem Areal nicht verfügbar." % plant_id)
			continue
		var cell := Vector2i(int(entry.get("x", 0)), int(entry.get("y", 0)))
		if not _soil_system.has_tilled_soil(cell):
			continue
		_plants[cell] = PlantState.from_dictionary(entry, definition)
		_soil_system.set_cell_has_plant(cell, true)
	queue_redraw()

func _rebuild_plant_index() -> void:
	_plants_by_id.clear()
	for plant in available_plants:
		if plant == null or not plant.is_valid_definition():
			continue
		if _plants_by_id.has(plant.plant_id):
			push_error("Pflanzen-ID '%s' ist im Areal doppelt vorhanden." % plant.plant_id)
			continue
		if not _item_database.has_item(plant.seed_item_id):
			push_error("Saatgut '%s' der Pflanze '%s' fehlt im Gegenstandskatalog." % [plant.seed_item_id, plant.plant_id])
			continue
		if not _item_database.has_item(plant.harvest_item_id):
			push_error("Erntegegenstand '%s' der Pflanze '%s' fehlt im Gegenstandskatalog." % [plant.harvest_item_id, plant.plant_id])
			continue
		_plants_by_id[plant.plant_id] = plant

func _on_previous_day_soil_state_ready(watered_cells: Array[Vector2i]) -> void:
	for cell_key in _plants:
		var cell: Vector2i = cell_key
		var state := _plants[cell] as PlantState
		if state == null or state.is_spoiled:
			continue

		if watered_cells.has(cell):
			state.consecutive_dry_days = 0
			if (
				_season_system.can_outdoor_plants_grow()
				and state.plant_data.is_available_in_season(_season_system.current_season)
			):
				state.grown_days = mini(state.grown_days + 1, state.plant_data.growth_days)
		else:
			state.consecutive_dry_days += 1
			if state.consecutive_dry_days >= dry_days_until_spoiled:
				state.is_spoiled = true
				plant_spoiled.emit(cell, state.plant_data)

		plant_changed.emit(cell)
	queue_redraw()

func _on_soil_cell_removed(cell: Vector2i) -> void:
	if has_plant(cell):
		_remove_plant(cell, false)

func _remove_plant(cell: Vector2i, update_soil: bool = true) -> void:
	if not _plants.erase(cell):
		return
	if update_soil:
		_soil_system.set_cell_has_plant(cell, false)
	plant_removed.emit(cell)
	queue_redraw()

func _draw() -> void:
	for cell_key in _plants:
		var cell: Vector2i = cell_key
		var state := _plants[cell] as PlantState
		if state == null or state.plant_data == null:
			continue

		var texture := state.plant_data.spoiled_texture if state.is_spoiled else _get_growth_texture(state)
		var center := to_local(_soil_system.cell_to_world_center(cell))
		if texture != null:
			draw_texture(texture, center - texture.get_size() * 0.5)
		else:
			_draw_placeholder(center, state)

func _get_growth_texture(state: PlantState) -> Texture2D:
	if state.plant_data.growth_stage_textures.is_empty():
		return null
	var stage := state.plant_data.get_growth_stage(state.grown_days)
	return state.plant_data.growth_stage_textures[stage]

func _draw_placeholder(center: Vector2, state: PlantState) -> void:
	var color := growing_placeholder_color
	if state.is_spoiled:
		color = spoiled_placeholder_color
	elif state.is_ready_for_harvest():
		color = ready_placeholder_color

	var progress := clampf(float(state.grown_days + 1) / float(state.plant_data.growth_days + 1), 0.2, 1.0)
	var size := Vector2(20.0, 26.0) * progress
	draw_rect(Rect2(center - size * 0.5, size), color, true)
