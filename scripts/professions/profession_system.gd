class_name ProfessionSystem
extends Node

signal experience_changed(
	profession_id: StringName,
	current_experience: int,
	required_experience: int,
	total_experience: int
)
signal level_changed(profession_id: StringName, new_level: int)

const WOODCUTTING: StringName = &"woodcutting"
const SMITHING: StringName = &"smithing"
const MINING: StringName = &"mining"
const COOKING: StringName = &"cooking"
const CRAFTING: StringName = &"crafting"
const FARMING: StringName = &"farming"
const COMBAT: StringName = &"combat"

@export_category("Levelsystem")
## Höchstes erreichbares Level jedes Berufs.
@export_range(1, 999, 1) var maximum_level: int = 50
## Benötigte Erfahrung für den nächsten Levelaufstieg. Der Wert 100 dient zunächst nur zum Testen.
@export_range(1, 999999, 1) var base_experience_per_level: int = 100
## Zusätzliche benötigte Erfahrung pro bereits erreichtem Level. Null hält die Testkurve vorerst gleichmäßig.
@export_range(0, 999999, 1) var additional_experience_per_level: int = 0

@export_category("Erfahrung abgeschlossener Tätigkeiten")
## Erfahrung für einen vollständig gefällten Baum im Beruf Holzfäller.
@export_range(0, 99999, 1) var felled_tree_experience: int = 10
## Erfahrung für einen vollständig abgebauten Stein im Beruf Bergbau.
@export_range(0, 99999, 1) var mined_stone_experience: int = 10
## Erfahrung für ein vollständig abgebautes Erzvorkommen im Beruf Bergbau.
@export_range(0, 99999, 1) var mined_ore_experience: int = 10
## Erfahrung für eine erfolgreich geerntete Pflanze im Beruf Landwirtschaft.
@export_range(0, 99999, 1) var harvested_crop_experience: int = 10
## Erfahrung für einen fertiggestellten Schmiedevorgang. Wird verwendet, sobald Schmieden eingebaut ist.
@export_range(0, 99999, 1) var forged_item_experience: int = 10
## Erfahrung für ein fertig gekochtes Gericht. Wird verwendet, sobald Kochen eingebaut ist.
@export_range(0, 99999, 1) var cooked_dish_experience: int = 10
## Erfahrung für ein fertig gebautes Hofobjekt. Wird verwendet, sobald Handwerk eingebaut ist.
@export_range(0, 99999, 1) var built_object_experience: int = 10
## Erfahrung für einen vollständig besiegten Gegner. Wird verwendet, sobald Kampf eingebaut ist.
@export_range(0, 99999, 1) var defeated_enemy_experience: int = 10

var _levels: Dictionary = {}
var _current_experience: Dictionary = {}
var _total_experience: Dictionary = {}

func _ready() -> void:
	_initialize_professions()

func connect_area(area: GameArea) -> void:
	if area == null:
		return
	var resource_system := area.get_node_or_null(^"ResourceSystem") as ResourceSystem
	if (
		resource_system != null
		and not resource_system.resource_depleted.is_connected(_on_resource_depleted)
	):
		resource_system.resource_depleted.connect(_on_resource_depleted)

	var plant_system := area.get_node_or_null(^"PlantSystem") as PlantSystem
	if plant_system != null and not plant_system.plant_harvested.is_connected(_on_plant_harvested):
		plant_system.plant_harvested.connect(_on_plant_harvested)

func add_experience(profession_id: StringName, amount: int) -> bool:
	if not _levels.has(profession_id):
		push_error("Unbekannter Beruf '%s' kann keine Erfahrung erhalten." % profession_id)
		return false
	if amount <= 0 or get_level(profession_id) >= maximum_level:
		return false

	var current_level := get_level(profession_id)
	var previous_level := current_level
	var current_amount := get_current_experience(profession_id) + amount
	var total_amount := get_total_experience(profession_id) + amount

	while current_level < maximum_level:
		var required_amount := get_required_experience_for_level(current_level)
		if current_amount < required_amount:
			break
		current_amount -= required_amount
		current_level += 1

	if current_level >= maximum_level:
		current_amount = 0

	_levels[profession_id] = current_level
	_current_experience[profession_id] = current_amount
	_total_experience[profession_id] = total_amount
	var reached_level := previous_level + 1
	while reached_level <= current_level:
		level_changed.emit(profession_id, reached_level)
		reached_level += 1
	experience_changed.emit(
		profession_id,
		current_amount,
		get_required_experience(profession_id),
		total_amount
	)
	return true

func get_level(profession_id: StringName) -> int:
	return int(_levels.get(profession_id, 0))

func get_current_experience(profession_id: StringName) -> int:
	return int(_current_experience.get(profession_id, 0))

func get_total_experience(profession_id: StringName) -> int:
	return int(_total_experience.get(profession_id, 0))

func get_required_experience(profession_id: StringName) -> int:
	var level := get_level(profession_id)
	if level <= 0 or level >= maximum_level:
		return 0
	return get_required_experience_for_level(level)

func get_required_experience_for_level(level: int) -> int:
	return maxi(base_experience_per_level + maxi(level - 1, 0) * additional_experience_per_level, 1)

func get_display_name(profession_id: StringName) -> String:
	match profession_id:
		WOODCUTTING:
			return "Holzfäller"
		SMITHING:
			return "Schmied"
		MINING:
			return "Bergbau"
		COOKING:
			return "Kochen"
		CRAFTING:
			return "Handwerk"
		FARMING:
			return "Landwirtschaft"
		COMBAT:
			return "Kampf"
	return "Unbekannt"

func get_profession_data() -> Array[Dictionary]:
	var data: Array[Dictionary] = []
	for profession_id in _get_starting_profession_ids():
		data.append({
			"profession_id": profession_id,
			"level": get_level(profession_id),
			"current_experience": get_current_experience(profession_id),
			"total_experience": get_total_experience(profession_id),
		})
	return data

func load_profession_data(data: Array[Dictionary]) -> void:
	_initialize_professions()
	for entry in data:
		var profession_id := StringName(entry.get("profession_id", ""))
		if not _levels.has(profession_id):
			continue
		var loaded_level := clampi(int(entry.get("level", 1)), 1, maximum_level)
		var loaded_experience := maxi(int(entry.get("current_experience", 0)), 0)
		if loaded_level >= maximum_level:
			loaded_experience = 0
		else:
			loaded_experience = mini(
				loaded_experience,
				get_required_experience_for_level(loaded_level) - 1
			)
		_levels[profession_id] = loaded_level
		_current_experience[profession_id] = loaded_experience
		_total_experience[profession_id] = maxi(
			int(entry.get("total_experience", loaded_experience)),
			loaded_experience
		)

func award_forged_item() -> bool:
	return add_experience(SMITHING, forged_item_experience)

func award_cooked_dish() -> bool:
	return add_experience(COOKING, cooked_dish_experience)

func award_built_object() -> bool:
	return add_experience(CRAFTING, built_object_experience)

func award_defeated_enemy() -> bool:
	return add_experience(COMBAT, defeated_enemy_experience)

func _initialize_professions() -> void:
	_levels.clear()
	_current_experience.clear()
	_total_experience.clear()
	for profession_id in _get_starting_profession_ids():
		_levels[profession_id] = 1
		_current_experience[profession_id] = 0
		_total_experience[profession_id] = 0

func _get_starting_profession_ids() -> Array[StringName]:
	var profession_ids: Array[StringName] = [
		WOODCUTTING,
		SMITHING,
		MINING,
		COOKING,
		CRAFTING,
		FARMING,
		COMBAT,
	]
	return profession_ids

func _on_resource_depleted(
	resource: HarvestableResource,
	_item_id: StringName,
	_amount: int
) -> void:
	if resource == null or resource.resource_data == null:
		return
	if resource.resource_data.required_tool_type == ToolData.ToolType.AXE:
		add_experience(WOODCUTTING, felled_tree_experience)
	elif resource.resource_data.resource_id == &"stone":
		add_experience(MINING, mined_stone_experience)
	else:
		add_experience(MINING, mined_ore_experience)

func _on_plant_harvested(
	_cell: Vector2i,
	_plant: PlantData,
	_amount: int
) -> void:
	add_experience(FARMING, harvested_crop_experience)
