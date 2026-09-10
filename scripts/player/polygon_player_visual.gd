class_name PolygonPlayerVisual
extends Node2D

## Geschwindigkeit der Laufbewegung von Armen und Beinen.
@export_range(1.0, 20.0, 0.5) var walk_animation_speed: float = 7.0
## Maximale Drehung der Arme und Beine während des Laufens.
@export_range(0.0, 45.0, 1.0) var limb_swing_degrees: float = 20.0
## Leichte Auf-und-ab-Bewegung des Körpers beim Laufen.
@export_range(0.0, 4.0, 0.25) var walk_bob_height: float = 1.5
## Einheitliche dunkle Außenlinie aller Körperteile.
@export var outline_color: Color = Color(0.055, 0.045, 0.04, 1.0)
## Hautfarbe der vorläufigen Polygon-Figur.
@export var skin_color: Color = Color(0.66, 0.43, 0.28, 1.0)
## Haarfarbe der vorläufigen Polygon-Figur.
@export var hair_color: Color = Color(0.16, 0.10, 0.065, 1.0)
## Farbe des einfachen Oberteils der vorläufigen Figur.
@export var shirt_color: Color = Color(0.48, 0.38, 0.25, 1.0)
## Farbe der einfachen Hose der vorläufigen Figur.
@export var trousers_color: Color = Color(0.20, 0.23, 0.22, 1.0)

var _player: PlayerMovement
var _walk_phase: float = 0.0
var _walk_blend: float = 0.0

func _ready() -> void:
	_player = get_parent() as PlayerMovement
	if _player == null:
		push_error("PolygonPlayerVisual muss direkt unter dem Spieler liegen.")
		set_process(false)
		return
	queue_redraw()

func _process(delta: float) -> void:
	var is_moving := _player.velocity.length_squared() > 1.0
	if is_moving:
		_walk_phase = fmod(_walk_phase + delta * walk_animation_speed, TAU)
		_walk_blend = minf(_walk_blend + delta * 8.0, 1.0)
	else:
		_walk_blend = maxf(_walk_blend - delta * 10.0, 0.0)
		if _walk_blend <= 0.0:
			_walk_phase = 0.0
	queue_redraw()

func _draw() -> void:
	if _player == null:
		return
	var bob_offset := -absf(sinf(_walk_phase * 2.0)) * walk_bob_height * _walk_blend
	var swing := sinf(_walk_phase) * deg_to_rad(limb_swing_degrees) * _walk_blend
	_draw_shadow()
	draw_set_transform(Vector2(0.0, bob_offset))
	if _player.facing_direction == Vector2i.LEFT:
		_draw_side(-1.0, swing)
	elif _player.facing_direction == Vector2i.RIGHT:
		_draw_side(1.0, swing)
	else:
		_draw_front_or_back(_player.facing_direction == Vector2i.UP, swing)
	draw_set_transform(Vector2.ZERO)

func _draw_shadow() -> void:
	_draw_part(
		PackedVector2Array([
			Vector2(-10.0, 20.0), Vector2(-6.0, 18.0), Vector2(6.0, 18.0),
			Vector2(10.0, 20.0), Vector2(6.0, 22.0), Vector2(-6.0, 22.0),
		]),
		Color(0.0, 0.0, 0.0, 0.24),
		Vector2.ZERO,
		0.0,
		1.0,
		false
	)

func _draw_front_or_back(is_back_view: bool, swing: float) -> void:
	_draw_part(_limb_polygon(5.0, 15.0), trousers_color.darkened(0.12), Vector2(-4.5, 7.0), swing)
	_draw_part(_limb_polygon(5.0, 15.0), trousers_color, Vector2(4.5, 7.0), -swing)
	_draw_part(_limb_polygon(4.5, 16.0), skin_color.darkened(0.12), Vector2(-8.0, -8.0), -swing)
	_draw_part(_limb_polygon(4.5, 16.0), skin_color, Vector2(8.0, -8.0), swing)
	_draw_part(
		PackedVector2Array([
			Vector2(-8.0, -10.0), Vector2(8.0, -10.0),
			Vector2(7.0, 9.0), Vector2(-7.0, 9.0),
		]),
		shirt_color.darkened(0.12) if is_back_view else shirt_color
	)
	_draw_part(
		PackedVector2Array([
			Vector2(-7.0, -21.0), Vector2(-4.0, -24.0), Vector2(4.0, -24.0),
			Vector2(7.0, -21.0), Vector2(7.0, -12.0), Vector2(4.0, -9.0),
			Vector2(-4.0, -9.0), Vector2(-7.0, -12.0),
		]),
		skin_color.darkened(0.08) if is_back_view else skin_color
	)
	var hair_points := PackedVector2Array([
		Vector2(-7.5, -21.0), Vector2(-4.0, -24.5), Vector2(4.5, -24.5),
		Vector2(7.5, -21.0), Vector2(7.0, -16.0), Vector2(4.0, -18.0),
		Vector2(1.0, -16.5), Vector2(-2.0, -18.5), Vector2(-7.0, -16.0),
	])
	_draw_part(hair_points, hair_color)
	if is_back_view:
		_draw_part(
			PackedVector2Array([
				Vector2(-7.0, -19.0), Vector2(7.0, -19.0),
				Vector2(6.0, -11.0), Vector2(-6.0, -11.0),
			]),
			hair_color,
			Vector2.ZERO,
			0.0,
			1.0,
			false
		)
	else:
		_draw_face()

func _draw_side(mirror: float, swing: float) -> void:
	_draw_part(_limb_polygon(5.0, 15.0), trousers_color.darkened(0.12), Vector2(-2.0, 7.0), -swing, mirror)
	_draw_part(_limb_polygon(5.0, 15.0), trousers_color, Vector2(3.0, 7.0), swing, mirror)
	_draw_part(_limb_polygon(4.5, 16.0), skin_color.darkened(0.14), Vector2(-2.0, -8.0), swing, mirror)
	_draw_part(
		PackedVector2Array([
			Vector2(-6.0, -10.0), Vector2(6.0, -10.0),
			Vector2(6.0, 9.0), Vector2(-5.0, 9.0),
		]),
		shirt_color,
		Vector2.ZERO,
		0.0,
		mirror
	)
	_draw_part(_limb_polygon(4.5, 16.0), skin_color, Vector2(5.0, -8.0), -swing, mirror)
	_draw_part(
		PackedVector2Array([
			Vector2(-6.0, -21.0), Vector2(-3.0, -24.0), Vector2(4.0, -23.0),
			Vector2(7.5, -19.0), Vector2(6.0, -11.0), Vector2(2.0, -9.0),
			Vector2(-5.0, -11.0),
		]),
		skin_color,
		Vector2.ZERO,
		0.0,
		mirror
	)
	_draw_part(
		PackedVector2Array([
			Vector2(-6.5, -21.0), Vector2(-3.0, -24.5), Vector2(4.0, -23.5),
			Vector2(6.0, -20.0), Vector2(2.0, -18.0), Vector2(-1.0, -16.0),
			Vector2(-6.0, -17.0),
		]),
		hair_color,
		Vector2.ZERO,
		0.0,
		mirror
	)
	_draw_part(
		PackedVector2Array([Vector2(4.2, -17.0), Vector2(5.7, -17.0), Vector2(5.7, -15.5), Vector2(4.2, -15.5)]),
		outline_color,
		Vector2.ZERO,
		0.0,
		mirror,
		false
	)

func _draw_face() -> void:
	_draw_part(
		PackedVector2Array([Vector2(-4.5, -17.5), Vector2(-2.5, -17.5), Vector2(-2.5, -15.5), Vector2(-4.5, -15.5)]),
		outline_color,
		Vector2.ZERO,
		0.0,
		1.0,
		false
	)
	_draw_part(
		PackedVector2Array([Vector2(2.5, -17.5), Vector2(4.5, -17.5), Vector2(4.5, -15.5), Vector2(2.5, -15.5)]),
		outline_color,
		Vector2.ZERO,
		0.0,
		1.0,
		false
	)

func _limb_polygon(width: float, length: float) -> PackedVector2Array:
	var half_width := width * 0.5
	return PackedVector2Array([
		Vector2(-half_width, 0.0), Vector2(half_width, 0.0),
		Vector2(half_width, length), Vector2(-half_width, length),
	])

func _draw_part(
	points: PackedVector2Array,
	color: Color,
	offset: Vector2 = Vector2.ZERO,
	rotation: float = 0.0,
	mirror: float = 1.0,
	with_outline: bool = true
) -> void:
	var transformed_points := PackedVector2Array()
	var transform := Transform2D(rotation, offset)
	for point in points:
		var transformed_point := transform * point
		transformed_point.x *= mirror
		transformed_points.append(transformed_point)
	draw_colored_polygon(transformed_points, color)
	if not with_outline or transformed_points.is_empty():
		return
	var outline_points := transformed_points.duplicate()
	outline_points.append(transformed_points[0])
	draw_polyline(outline_points, outline_color, 1.25, false)
