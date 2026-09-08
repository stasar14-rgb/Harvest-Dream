class_name GameArea
extends Node2D

@export var camera_bounds: Rect2i = Rect2i(0, 0, 640, 360)
@export var default_spawn_id: StringName = &"default"

@onready var spawn_points := get_node_or_null(^"SpawnPoints") as Node2D

func get_camera_bounds() -> Rect2i:
	return camera_bounds

func get_spawn_point(requested_id: StringName = &"") -> AreaSpawnPoint:
	if spawn_points == null:
		push_error("Im Areal '%s' fehlt der Node SpawnPoints." % name)
		return null

	var target_id := requested_id if requested_id != &"" else default_spawn_id

	for child in spawn_points.get_children():
		if child is AreaSpawnPoint and child.spawn_id == target_id:
			return child

	push_error("Spawnpunkt '%s' wurde im Areal '%s' nicht gefunden." % [target_id, name])
	return null
