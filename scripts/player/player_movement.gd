class_name PlayerMovement
extends CharacterBody2D

## Bewegungsgeschwindigkeit des Spielers in Pixeln pro Sekunde.
@export var move_speed: float = 100.0

var facing_direction: Vector2i = Vector2i.DOWN

@onready var character_sprite: AnimatedSprite2D = $CharacterSprite

func _ready() -> void:
	_show_idle_frame()

func _physics_process(_delta: float) -> void:
	var input_direction := Input.get_vector(
		"move_left",
		"move_right",
		"move_up",
		"move_down"
	)
	_update_facing_direction(input_direction)
	_update_walk_animation(input_direction)
	velocity = input_direction * move_speed
	move_and_slide()

func _update_facing_direction(input_direction: Vector2) -> void:
	if input_direction.is_zero_approx():
		return

	if absf(input_direction.x) > absf(input_direction.y):
		facing_direction = Vector2i.RIGHT if input_direction.x > 0.0 else Vector2i.LEFT
	else:
		facing_direction = Vector2i.DOWN if input_direction.y > 0.0 else Vector2i.UP

func _update_walk_animation(input_direction: Vector2) -> void:
	var animation_name := _get_walk_animation_name()
	if input_direction.is_zero_approx():
		if character_sprite.animation != animation_name:
			character_sprite.animation = animation_name
		character_sprite.pause()
		character_sprite.frame = 0
		return

	character_sprite.play(animation_name)

func _show_idle_frame() -> void:
	character_sprite.animation = _get_walk_animation_name()
	character_sprite.frame = 0
	character_sprite.pause()

func _get_walk_animation_name() -> StringName:
	if facing_direction == Vector2i.LEFT:
		return &"walk_left"
	if facing_direction == Vector2i.RIGHT:
		return &"walk_right"
	if facing_direction == Vector2i.UP:
		return &"walk_up"
	return &"walk_down"
