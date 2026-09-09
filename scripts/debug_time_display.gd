extends Label

var _calendar: GameCalendar
var _season_system: SeasonSystem

func _ready() -> void:
	_calendar = get_tree().get_first_node_in_group(&"game_calendar") as GameCalendar
	_season_system = get_tree().get_first_node_in_group(&"season_system") as SeasonSystem

	if _calendar == null:
		push_error("Die Debug-Zeitanzeige findet keinen GameCalendar.")
		return

	if _season_system == null:
		push_error("Die Debug-Zeitanzeige findet kein SeasonSystem.")
		return

	_calendar.time_changed.connect(_update_display)
	_calendar.date_changed.connect(_update_display_from_date)
	_calendar.time_pause_changed.connect(_update_display_from_pause)
	_season_system.season_rules_changed.connect(_update_display_from_season)
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

func _update_text() -> void:
	var pause_text := "  [ZEIT PAUSIERT]" if _calendar.is_time_paused() else ""
	var season_rule_text := "Außenpflanzen und Pilze verfügbar"

	if _season_system.is_winter():
		season_rule_text = "Winter: kein Außenwachstum, keine Pilze, Winterfrüchte verfügbar"

	text = "%s\n%s%s\n%s" % [
		_calendar.get_date_text(),
		_calendar.get_time_text(),
		pause_text,
		season_rule_text,
	]
