class_name GameArea
extends Node2D

@export var camera_bounds: Rect2i = Rect2i(0, 0, 640, 360)

func get_camera_bounds() -> Rect2i:
	return camera_bounds
