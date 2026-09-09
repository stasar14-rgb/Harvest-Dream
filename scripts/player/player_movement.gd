class_name PlayerMovement
extends CharacterBody2D

## Bewegungsgeschwindigkeit des Spielers in Pixeln pro Sekunde.
@export var move_speed: float = 100.0

var facing_direction: Vector2i = Vector2i.DOWN

func _physics_process(_delta: float) -> void:
	var input_direction := Input.get_vector(
		"move_left",
		"move_right",
		"move_up",
		"move_down"
	)
	_update_facing_direction(input_direction)
	velocity = input_direction * move_speed
	move_and_slide()

func _update_facing_direction(input_direction: Vector2) -> void:
	if input_direction.is_zero_approx():
		return

	if absf(input_direction.x) > absf(input_direction.y):
		facing_direction = Vector2i.RIGHT if input_direction.x > 0.0 else Vector2i.LEFT
	else:
		facing_direction = Vector2i.DOWN if input_direction.y > 0.0 else Vector2i.UP
