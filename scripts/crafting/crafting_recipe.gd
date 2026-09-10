class_name CraftingRecipe
extends Resource

## Eindeutige interne ID des Rezepts.
@export var recipe_id: StringName = &""
## Sichtbarer Name des hergestellten Gegenstands.
@export var display_name: String = ""
## ID des Gegenstands, der nach erfolgreicher Herstellung entsteht.
@export var output_item_id: StringName = &""
## Anzahl der Gegenstände, die pro Herstellungsvorgang entsteht.
@export_range(1, 999, 1) var output_amount: int = 1
## Benötigte Rohstoff-IDs. Die Positionen müssen zu den Mengen passen.
@export var ingredient_item_ids: Array[StringName] = []
## Benötigte Rohstoffmengen pro einzelnem Herstellungsvorgang.
@export var ingredient_amounts: Array[int] = []
## Reale Sekunden, die ein einzelner Herstellungsvorgang benötigt.
@export_range(0.1, 36000.0, 0.1) var crafting_seconds: float = 60.0

func get_ingredient_amount(item_id: StringName) -> int:
	var total := 0
	for index in ingredient_item_ids.size():
		if ingredient_item_ids[index] == item_id:
			total += ingredient_amounts[index]
	return total

func is_valid_definition() -> bool:
	if recipe_id == &"" or display_name.is_empty() or output_item_id == &"":
		push_error("Ein Herstellungsrezept benötigt ID, Namen und Ausgabegegenstand.")
		return false
	if ingredient_item_ids.is_empty() or ingredient_item_ids.size() != ingredient_amounts.size():
		push_error("Rezept '%s' besitzt unvollständige Zutaten." % recipe_id)
		return false
	for index in ingredient_item_ids.size():
		if ingredient_item_ids[index] == &"" or ingredient_amounts[index] <= 0:
			push_error("Rezept '%s' besitzt eine ungültige Zutat." % recipe_id)
			return false
	return output_amount > 0 and crafting_seconds > 0.0
