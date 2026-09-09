extends Node

signal area_changed(
	area_id: StringName,
	display_name: String,
	area_path: String,
	spawn_id: StringName
)

## Spawnpunkt, an dem der Spieler beim Start eines neuen Spiels erscheint.
@export var start_spawn_id: StringName = &"default"

@onready var game_calendar: GameCalendar = $GameCalendar
@onready var area_container: Node2D = $AreaContainer
@onready var player: CharacterBody2D = $Player
@onready var player_camera: Camera2D = $Player/Camera2D

var current_area: GameArea
var current_area_id: StringName = &""
var current_area_name: String = ""
var current_area_path: String = ""
var current_spawn_id: StringName = &""

var _area_change_in_progress := false

func _ready() -> void:
	if area_container.get_child_count() == 0:
		push_error("AreaContainer enthält kein Areal.")
		return

	current_area = area_container.get_child(0) as GameArea
	if current_area == null:
		push_error("Das geladene Areal verwendet nicht die GameArea-Grundlage.")
		return

	if not current_area.has_valid_identity():
		return

	_configure_area(current_area)
	if place_player_at_spawn(start_spawn_id):
		_update_current_location(start_spawn_id)

func place_player_at_spawn(spawn_id: StringName = &"") -> bool:
	if current_area == null:
		push_error("Es ist kein gültiges Areal geladen.")
		return false

	var spawn_point := current_area.get_spawn_point(spawn_id)
	if spawn_point == null:
		return false

	player.global_position = spawn_point.global_position
	return true

func request_area_change(target_area_path: String, target_spawn_id: StringName = &"default") -> void:
	if _area_change_in_progress:
		return

	if target_area_path.is_empty():
		push_error("Ein Arealwechsel ohne Zielkarte wurde angefordert.")
		return

	_area_change_in_progress = true
	_perform_area_change.call_deferred(target_area_path, target_spawn_id)

func _perform_area_change(target_area_path: String, target_spawn_id: StringName) -> void:
	if not ResourceLoader.exists(target_area_path, "PackedScene"):
		push_error("Die Zielkarte '%s' wurde nicht gefunden." % target_area_path)
		_area_change_in_progress = false
		return

	var area_scene := ResourceLoader.load(target_area_path, "PackedScene") as PackedScene
	if area_scene == null:
		push_error("Die Zielkarte '%s' konnte nicht geladen werden." % target_area_path)
		_area_change_in_progress = false
		return

	var next_area_node := area_scene.instantiate()
	var next_area := next_area_node as GameArea
	if next_area == null:
		next_area_node.free()
		push_error("Die Zielkarte '%s' verwendet nicht die GameArea-Grundlage." % target_area_path)
		_area_change_in_progress = false
		return

	if not next_area.has_valid_identity():
		next_area.free()
		_area_change_in_progress = false
		return

	area_container.add_child(next_area)

	var target_spawn := next_area.get_spawn_point(target_spawn_id)
	if target_spawn == null:
		area_container.remove_child(next_area)
		next_area.free()
		_area_change_in_progress = false
		return

	var previous_area := current_area
	current_area = next_area
	_configure_area(current_area)
	player.global_position = target_spawn.global_position

	if previous_area != null:
		area_container.remove_child(previous_area)
		previous_area.queue_free()

	_update_current_location(target_spawn_id, target_area_path)
	_area_change_in_progress = false

func _update_current_location(spawn_id: StringName, area_path: String = "") -> void:
	current_area_id = current_area.get_area_id()
	current_area_name = current_area.get_display_name()
	current_area_path = area_path if not area_path.is_empty() else current_area.scene_file_path
	current_spawn_id = spawn_id

	area_changed.emit(
		current_area_id,
		current_area_name,
		current_area_path,
		current_spawn_id
	)

func _configure_area(area: GameArea) -> void:
	_apply_camera_bounds(area.get_camera_bounds())
	_apply_area_time_rule(area)

	if not area.area_change_requested.is_connected(_on_area_change_requested):
		area.area_change_requested.connect(_on_area_change_requested)

func _apply_area_time_rule(area: GameArea) -> void:
	if area.pauses_time:
		game_calendar.pause_time(GameCalendar.PAUSE_REASON_INTERIOR)
	else:
		game_calendar.resume_time(GameCalendar.PAUSE_REASON_INTERIOR)

func _on_area_change_requested(target_area_path: String, target_spawn_id: StringName) -> void:
	request_area_change(target_area_path, target_spawn_id)

func _apply_camera_bounds(bounds: Rect2i) -> void:
	player_camera.limit_left = bounds.position.x
	player_camera.limit_top = bounds.position.y
	player_camera.limit_right = bounds.end.x
	player_camera.limit_bottom = bounds.end.y
