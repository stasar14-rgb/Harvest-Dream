class_name InventorySlot
extends Resource

var item_id: StringName = &""
var amount: int = 0

func is_empty() -> bool:
	return item_id == &"" or amount <= 0

func set_stack(new_item_id: StringName, new_amount: int) -> void:
	item_id = new_item_id
	amount = max(new_amount, 0)
	if amount == 0:
		item_id = &""

func clear() -> void:
	item_id = &""
	amount = 0
