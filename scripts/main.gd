extends Node

@export var start_spawn_id: StringName = &"default"

@onready var area_container: Node2D = $AreaContainer
@onready var player: CharacterBody2D = $Player
@onready var player_camera: Camera2D = $Player/Camera2D

var current_area: GameArea
var _area_change_in_progress := false

func _ready() -> void:
	if area_container.get_child_count() == 0:
		push_error("AreaContainer enthält kein Areal.")
		return

	current_area = area_container.get_child(0) as GameArea
	if current_area == null:
		push_error("Das geladene Areal verwendet nicht die GameArea-Grundlage.")
		return

	_configure_area(current_area)
	place_player_at_spawn(start_spawn_id)

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

	var next_area := area_scene.instantiate() as GameArea
	if next_area == null:
		push_error("Die Zielkarte '%s' verwendet nicht die GameArea-Grundlage." % target_area_path)
		_area_change_in_progress = false
		return

	area_container.add_child(next_area)

	var target_spawn := next_area.get_spawn_point(target_spawn_id)
	if target_spawn == null:
		area_container.remove_child(next_area)
		next_area.queue_free()
		_area_change_in_progress = false
		return

	var previous_area := current_area
	current_area = next_area
	_configure_area(current_area)
	player.global_position = target_spawn.global_position

	if previous_area != null:
		area_container.remove_child(previous_area)
		previous_area.queue_free()

	_area_change_in_progress = false

func _configure_area(area: GameArea) -> void:
	_apply_camera_bounds(area.get_camera_bounds())

	if not area.area_change_requested.is_connected(_on_area_change_requested):
		area.area_change_requested.connect(_on_area_change_requested)

func _on_area_change_requested(target_area_path: String, target_spawn_id: StringName) -> void:
	request_area_change(target_area_path, target_spawn_id)

func _apply_camera_bounds(bounds: Rect2i) -> void:
	player_camera.limit_left = bounds.position.x
	player_camera.limit_top = bounds.position.y
	player_camera.limit_right = bounds.end.x
	player_camera.limit_bottom = bounds.end.y
