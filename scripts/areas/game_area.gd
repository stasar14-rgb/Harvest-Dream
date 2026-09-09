class_name GameArea
extends Node2D

signal area_change_requested(target_area_path: String, target_spawn_id: StringName)

## Eindeutige interne ID des Areals. Nach Veröffentlichung nicht mehr ändern.
@export var area_id: StringName = &""
## Sichtbarer Name des Areals, der später in Karte und Oberfläche angezeigt wird.
@export var display_name: String = ""
## Pausiert die Spielzeit in diesem Areal, zum Beispiel in Häusern.
@export var pauses_time: bool = false
## Begrenzung, innerhalb der sich die Kamera in diesem Areal bewegen darf.
@export var camera_bounds: Rect2i = Rect2i(0, 0, 1280, 720)
## Spawnpunkt, der verwendet wird, wenn keine andere Spawn-ID angegeben wurde.
@export var default_spawn_id: StringName = &"default"

@onready var spawn_points := get_node_or_null(^"SpawnPoints") as Node2D
@onready var transitions := get_node_or_null(^"Transitions") as Node2D

func _ready() -> void:
	if transitions == null:
		return

	for child in transitions.get_children():
		if child is AreaTransition:
			child.transition_requested.connect(_on_transition_requested)

func has_valid_identity() -> bool:
	if area_id == &"":
		push_error("Im Areal '%s' fehlt die area_id." % name)
		return false

	if display_name.is_empty():
		push_error("Im Areal '%s' fehlt der sichtbare Name." % name)
		return false

	return true

func get_area_id() -> StringName:
	return area_id

func get_display_name() -> String:
	return display_name

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

func _on_transition_requested(target_area_path: String, target_spawn_id: StringName) -> void:
	area_change_requested.emit(target_area_path, target_spawn_id)
