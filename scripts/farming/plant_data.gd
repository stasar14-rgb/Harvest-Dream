class_name PlantData
extends Resource

## Eindeutige interne ID der Pflanzenart. Nach Verwendung in Spielständen nicht mehr ändern.
@export var plant_id: StringName = &""
## Sichtbarer Name der Pflanze für Anzeigen und spätere Informationsfenster.
@export var display_name: String = ""
## Gegenstands-ID des Saatguts, das beim Einpflanzen verbraucht wird.
@export var seed_item_id: StringName = &""
## Gegenstands-ID des Ernteprodukts, das nach vollständigem Wachstum entsteht.
@export var harvest_item_id: StringName = &""
## Anzahl bewässerter Wachstumstage bis zur Erntereife.
@export_range(1, 9999, 1) var growth_days: int = 1
## Kleinste Anzahl an Gegenständen, die eine erfolgreiche Ernte liefern kann.
@export_range(1, 999, 1) var minimum_harvest_amount: int = 1
## Größte Anzahl an Gegenständen, die eine erfolgreiche Ernte liefern kann.
@export_range(1, 999, 1) var maximum_harvest_amount: int = 1
## Erlaubte Jahreszeiten als Kalenderwerte: 0 Frühling, 1 Sommer, 2 Herbst und 3 Winter. Eine leere Liste erlaubt jede Jahreszeit.
@export var allowed_seasons: Array[int] = []
## Später austauschbare Bilder der Wachstumsstufen. Ohne Bilder verwendet das Testsystem Platzhalter.
@export var growth_stage_textures: Array[Texture2D] = []
## Später austauschbares Bild einer verdorbenen Pflanze. Ohne Bild wird ein grauer Platzhalter verwendet.
@export var spoiled_texture: Texture2D

func is_available_in_season(season: int) -> bool:
	return allowed_seasons.is_empty() or allowed_seasons.has(season)

func roll_harvest_amount() -> int:
	return randi_range(minimum_harvest_amount, maximum_harvest_amount)

func get_growth_stage(grown_days: int) -> int:
	if growth_stage_textures.is_empty():
		return 0

	var progress := clampf(float(grown_days) / float(growth_days), 0.0, 1.0)
	return mini(floori(progress * float(growth_stage_textures.size())), growth_stage_textures.size() - 1)

func is_valid_definition() -> bool:
	if plant_id == &"":
		push_error("Eine Pflanzendefinition besitzt keine ID.")
		return false
	if display_name.is_empty():
		push_error("Pflanze '%s' besitzt keinen Namen." % plant_id)
		return false
	if seed_item_id == &"" or harvest_item_id == &"":
		push_error("Pflanze '%s' benötigt Saatgut- und Erntegegenstands-IDs." % plant_id)
		return false
	if growth_days < 1 or minimum_harvest_amount < 1:
		push_error("Pflanze '%s' besitzt ungültige Wachstums- oder Erntewerte." % plant_id)
		return false
	if maximum_harvest_amount < minimum_harvest_amount:
		push_error("Pflanze '%s' besitzt eine kleinere maximale als minimale Erntemenge." % plant_id)
		return false
	for season in allowed_seasons:
		if season < GameCalendar.Month.SPRING or season > GameCalendar.Month.WINTER:
			push_error("Pflanze '%s' enthält eine ungültige Jahreszeit." % plant_id)
			return false
	return true
