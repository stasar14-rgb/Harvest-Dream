class_name PlayerInteractor
extends Area2D

signal focused_interactable_changed(interactable: Interactable)

## Maximale Entfernung in Pixeln, aus der der Spieler ein Objekt mit E benutzen kann.
@export_range(1.0, 256.0, 1.0) var interaction_range: float = 32.0

var _candidates: Array[Interactable] = []
var _focused_interactable: Interactable

func _ready() -> void:
	area_entered.connect(_on_area_entered)
	area_exited.connect(_on_area_exited)

func _physics_process(_delta: float) -> void:
	_refresh_focused_interactable()

func _unhandled_input(event: InputEvent) -> void:
	if not event.is_action_pressed(&"interact"):
		return

	if _focused_interactable == null:
		return

	if _focused_interactable.interact(get_parent() as Node2D):
		get_viewport().set_input_as_handled()

func _on_area_entered(area: Area2D) -> void:
	if area is not Interactable:
		return

	var interactable := area as Interactable
	if not _candidates.has(interactable):
		_candidates.append(interactable)

	_refresh_focused_interactable()

func _on_area_exited(area: Area2D) -> void:
	if area is not Interactable:
		return

	_candidates.erase(area as Interactable)
	_refresh_focused_interactable()

func _refresh_focused_interactable() -> void:
	var nearest: Interactable
	var nearest_distance := interaction_range

	for candidate in _candidates.duplicate():
		if not is_instance_valid(candidate):
			_candidates.erase(candidate)
			continue

		if not candidate.is_available():
			continue

		var distance := global_position.distance_to(candidate.global_position)
		if distance <= nearest_distance:
			nearest = candidate
			nearest_distance = distance

	_set_focused_interactable(nearest)

func _set_focused_interactable(next_interactable: Interactable) -> void:
	if _focused_interactable == next_interactable:
		return

	if is_instance_valid(_focused_interactable):
		_focused_interactable.set_highlighted(false)

	_focused_interactable = next_interactable

	if _focused_interactable != null:
		_focused_interactable.set_highlighted(true)

	focused_interactable_changed.emit(_focused_interactable)
