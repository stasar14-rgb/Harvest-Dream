class_name AreaTransition
extends Area2D

signal transition_requested(target_area_path: String, target_spawn_id: StringName)

@export_file("*.tscn") var target_area_path: String = ""
@export var target_spawn_id: StringName = &"default"
@export var transition_enabled: bool = true

var _request_sent := false

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if not transition_enabled or _request_sent:
		return

	if not body.is_in_group(&"player"):
		return

	if target_area_path.is_empty():
		push_error("Beim Arealübergang '%s' fehlt die Zielkarte." % name)
		return

	_request_sent = true
	transition_requested.emit(target_area_path, target_spawn_id)
