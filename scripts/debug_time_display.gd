extends Label

var _calendar: GameCalendar

func _ready() -> void:
	_calendar = get_tree().get_first_node_in_group(&"game_calendar") as GameCalendar
	if _calendar == null:
		push_error("Die Debug-Zeitanzeige findet keinen GameCalendar.")
		return

	_calendar.time_changed.connect(_update_display)
	_calendar.date_changed.connect(_update_display_from_date)
	_calendar.time_pause_changed.connect(_update_display_from_pause)
	_update_text()

func _update_display(_hour: int, _minute: int) -> void:
	_update_text()

func _update_display_from_date(_year: int, _month: int, _day: int) -> void:
	_update_text()

func _update_display_from_pause(_is_paused: bool) -> void:
	_update_text()

func _update_text() -> void:
	var pause_text := "  [ZEIT PAUSIERT]" if _calendar.is_time_paused() else ""
	text = "%s\n%s%s" % [
		_calendar.get_date_text(),
		_calendar.get_time_text(),
		pause_text,
	]
