extends Label

var _calendar: GameCalendar
var _season_system: SeasonSystem
var _player_energy: PlayerEnergy
var _item_database: ItemDatabase

func _ready() -> void:
	_calendar = get_tree().get_first_node_in_group(&"game_calendar") as GameCalendar
	_season_system = get_tree().get_first_node_in_group(&"season_system") as SeasonSystem
	_player_energy = get_tree().get_first_node_in_group(&"player_energy") as PlayerEnergy
	_item_database = get_tree().get_first_node_in_group(&"item_database") as ItemDatabase

	if _calendar == null:
		push_error("Die Debug-Zeitanzeige findet keinen GameCalendar.")
		return

	if _season_system == null:
		push_error("Die Debug-Zeitanzeige findet kein SeasonSystem.")
		return

	if _player_energy == null:
		push_error("Die Debug-Zeitanzeige findet keine PlayerEnergy.")
		return

	if _item_database == null:
		push_error("Die Debug-Anzeige findet keine ItemDatabase.")
		return

	_calendar.time_changed.connect(_update_display)
	_calendar.date_changed.connect(_update_display_from_date)
	_calendar.time_pause_changed.connect(_update_display_from_pause)
	_season_system.season_rules_changed.connect(_update_display_from_season)
	_player_energy.energy_changed.connect(_update_display_from_energy)
	_player_energy.warm_clothing_changed.connect(_update_display_from_clothing)
	_update_text()

func _update_display(_hour: int, _minute: int) -> void:
	_update_text()

func _update_display_from_date(_year: int, _month: int, _day: int) -> void:
	_update_text()

func _update_display_from_pause(_is_paused: bool) -> void:
	_update_text()

func _update_display_from_season(
	_outdoor_plants_can_grow: bool,
	_mushrooms_can_spawn: bool,
	_winter_fruits_can_spawn: bool,
	_warm_clothing_required: bool
) -> void:
	_update_text()

func _update_display_from_energy(_current_energy: float, _maximum_energy: float) -> void:
	_update_text()

func _update_display_from_clothing(_is_active: bool) -> void:
	_update_text()

func _update_text() -> void:
	var pause_text := "  [ZEIT PAUSIERT]" if _calendar.is_time_paused() else ""
	var season_rule_text := "Außenpflanzen und Pilze verfügbar"

	if _season_system.is_winter():
		if _player_energy.has_warm_clothing():
			season_rule_text = "Winter: warme Kleidung aktiv, normale Energiekosten"
		else:
			season_rule_text = "Winter: kein Außenwachstum, Energiekosten +25 %"

	text = "%s\n%s%s\nEnergie: %.1f / %.1f\nKatalog: %d Gegenstände\n%s" % [
		_calendar.get_date_text(),
		_calendar.get_time_text(),
		pause_text,
		_player_energy.current_energy,
		_player_energy.maximum_energy,
		_item_database.get_item_count(),
		season_rule_text,
	]
