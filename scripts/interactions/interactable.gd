class_name Interactable
extends Area2D

signal interaction_requested(interactor: Node2D)

@export var interaction_name: String = "Interagieren"
@export var interaction_enabled: bool = true
@export var highlight_path: NodePath = ^"Highlight"
@export var debug_log_interactions: bool = false

@onready var _highlight := get_node_or_null(highlight_path) as CanvasItem

func _ready() -> void:
	set_highlighted(false)

func interact(interactor: Node2D) -> bool:
	if not interaction_enabled:
		return false

	interaction_requested.emit(interactor)

	if debug_log_interactions:
		print("Interaktion ausgelöst: %s" % interaction_name)

	return true

func is_available() -> bool:
	return interaction_enabled

func set_highlighted(is_highlighted: bool) -> void:
	if _highlight != null:
		_highlight.visible = is_highlighted
