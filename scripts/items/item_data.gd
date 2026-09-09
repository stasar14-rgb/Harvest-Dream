class_name ItemData
extends Resource

enum Category {
	MATERIAL,
	FOOD,
	CONSUMABLE,
	FISH,
	SEED,
	SAPLING,
	TOOL,
	OTHER,
}

const MATERIAL_STACK_LIMIT := 99
const FOOD_STACK_LIMIT := 10
const CONSUMABLE_STACK_LIMIT := 10
const FISH_STACK_LIMIT := 20
const NON_STACKABLE_LIMIT := 1

@export var item_id: StringName = &""
@export var display_name: String = ""
@export_multiline var description: String = ""
@export var icon: Texture2D
@export var category: Category = Category.OTHER
@export var rarity_id: StringName = &"normal"
@export_range(0, 999999, 1) var base_price: int = 0
@export_range(0, 999, 1) var stack_limit_override: int = 0
@export_range(0, 9999, 1) var growth_duration_days: int = 0
@export var supports_quality: bool = false

func get_stack_limit() -> int:
	if stack_limit_override > 0:
		return stack_limit_override

	match category:
		Category.MATERIAL:
			return MATERIAL_STACK_LIMIT
		Category.FOOD:
			return FOOD_STACK_LIMIT
		Category.CONSUMABLE:
			return CONSUMABLE_STACK_LIMIT
		Category.FISH:
			return FISH_STACK_LIMIT
		_:
			return NON_STACKABLE_LIMIT

func is_stackable() -> bool:
	return get_stack_limit() > 1

func has_growth_duration() -> bool:
	return category == Category.SEED or category == Category.SAPLING

func is_valid_definition() -> bool:
	if item_id == &"":
		push_error("Ein Gegenstand im Katalog besitzt keine ID.")
		return false

	if display_name.is_empty():
		push_error("Der Gegenstand '%s' besitzt keinen Namen." % item_id)
		return false

	if get_stack_limit() < 1:
		push_error("Der Gegenstand '%s' besitzt eine ungültige Stapelgröße." % item_id)
		return false

	if growth_duration_days > 0 and not has_growth_duration():
		push_error("Nur Saatgut und Setzlinge dürfen eine Wachstumsdauer besitzen: %s" % item_id)
		return false

	return true
