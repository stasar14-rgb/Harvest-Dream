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

## Eindeutige interne ID des Gegenstands. Nach Verwendung in Spielständen nicht mehr ändern.
@export var item_id: StringName = &""
## Sichtbarer Name des Gegenstands im Inventar und in anderen Menüs.
@export var display_name: String = ""
## Kurze Beschreibung des Gegenstands für Inventar und Informationsfenster.
@export_multiline var description: String = ""
## 32×32-Pixel-Icon des Gegenstands. Das Bild kann ohne Skriptänderung ersetzt werden.
@export var icon: Texture2D
## Kategorie des Gegenstands. Sie bestimmt unter anderem die Standard-Stapelgröße.
@export var category: Category = Category.OTHER
## Interne ID der Seltenheitsstufe. Vorerst wird „normal“ verwendet.
@export var rarity_id: StringName = &"normal"
## Grundpreis des Gegenstands vor späteren Preisänderungen oder Boni.
@export_range(0, 999999, 1) var base_price: int = 0
## Eigene Stapelgröße. Wert 0 verwendet den Standard der Gegenstandskategorie.
@export_range(0, 999, 1) var stack_limit_override: int = 0
## Benötigte Wachstumstage für Saatgut oder Setzlinge. Wert 0 bedeutet keine Wachstumsdauer.
@export_range(0, 9999, 1) var growth_duration_days: int = 0
## Bereitet Qualitätsstufen für diesen Gegenstand vor. Das Qualitätssystem folgt später.
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
