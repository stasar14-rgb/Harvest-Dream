extends Node

@onready var current_area: GameArea = $TestArea
@onready var player_camera: Camera2D = $Player/Camera2D

func _ready() -> void:
	_apply_camera_bounds(current_area.get_camera_bounds())

func _apply_camera_bounds(bounds: Rect2i) -> void:
	player_camera.limit_left = bounds.position.x
	player_camera.limit_top = bounds.position.y
	player_camera.limit_right = bounds.end.x
	player_camera.limit_bottom = bounds.end.y
