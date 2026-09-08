extends Node

@export var start_spawn_id: StringName = &"default"

@onready var area_container: Node2D = $AreaContainer
@onready var player: CharacterBody2D = $Player
@onready var player_camera: Camera2D = $Player/Camera2D

var current_area: GameArea

func _ready() -> void:
	if area_container.get_child_count() == 0:
		push_error("AreaContainer enthält kein Areal.")
		return

	current_area = area_container.get_child(0) as GameArea
	if current_area == null:
		push_error("Das geladene Areal verwendet nicht die GameArea-Grundlage.")
		return

	_apply_camera_bounds(current_area.get_camera_bounds())
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

func _apply_camera_bounds(bounds: Rect2i) -> void:
	player_camera.limit_left = bounds.position.x
	player_camera.limit_top = bounds.position.y
	player_camera.limit_right = bounds.end.x
	player_camera.limit_bottom = bounds.end.y
