class_name GroundItem
extends Node2D

signal emptied(item: GroundItem)

var item_data: ItemData
var amount: int = 0
var placeholder_size: Vector2 = Vector2(16.0, 16.0)
var placeholder_color: Color = Color(0.95, 0.82, 0.28, 1.0)

func setup(new_item_data: ItemData, new_amount: int, size: Vector2, color: Color) -> void:
	item_data = new_item_data
	amount = maxi(new_amount, 0)
	placeholder_size = size
	placeholder_color = color
	queue_redraw()

func get_free_stack_space() -> int:
	if item_data == null:
		return 0
	return maxi(item_data.get_stack_limit() - amount, 0)

func add_amount(added_amount: int) -> int:
	if item_data == null or added_amount <= 0:
		return added_amount
	var accepted_amount := mini(added_amount, get_free_stack_space())
	amount += accepted_amount
	queue_redraw()
	return added_amount - accepted_amount

func remove_amount(removed_amount: int) -> int:
	var actual_amount := mini(maxi(removed_amount, 0), amount)
	amount -= actual_amount
	if amount == 0:
		emptied.emit(self)
	queue_redraw()
	return actual_amount

func get_save_data() -> Dictionary:
	return {
		"item_id": item_data.item_id if item_data != null else &"",
		"amount": amount,
		"x": global_position.x,
		"y": global_position.y,
	}

func _draw() -> void:
	if item_data == null or amount <= 0:
		return
	if item_data.icon != null:
		draw_texture(item_data.icon, -item_data.icon.get_size() * 0.5)
		return
	draw_rect(Rect2(-placeholder_size * 0.5, placeholder_size), placeholder_color, true)
