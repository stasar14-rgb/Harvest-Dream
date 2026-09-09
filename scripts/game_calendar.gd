class_name GameCalendar
extends Node

signal day_changed(day: int)
signal month_changed(month: int)
signal year_changed(year: int)
signal date_changed(year: int, month: int, day: int)
signal time_changed(hour: int, minute: int)
signal time_pause_changed(is_paused: bool)
signal forced_sleep(energy_penalty_percent: int)
signal day_started(
	year: int,
	month: int,
	day: int,
	wake_hour: int,
	was_forced_sleep: bool
)

enum Month {
	SPRING,
	SUMMER,
	AUTUMN,
	WINTER,
}

const DAYS_PER_MONTH := 28
const MONTHS_PER_YEAR := 4
const NORMAL_WAKE_HOUR := 6
const FORCED_SLEEP_HOUR := 2
const FORCED_WAKE_HOUR := 8
const FORCED_SLEEP_ENERGY_PENALTY_PERCENT := 20
const REAL_SECONDS_PER_GAME_MINUTE := 1.0

const PAUSE_REASON_MENU: StringName = &"menu"
const PAUSE_REASON_DIALOGUE: StringName = &"dialogue"
const PAUSE_REASON_INTERIOR: StringName = &"interior"

const MONTH_NAMES: Array[String] = [
	"Frühling",
	"Sommer",
	"Herbst",
	"Winter",
]

@export_range(1, 28, 1) var current_day: int = 1
@export var current_month: Month = Month.SPRING
@export_range(1, 9999, 1) var current_year: int = 1
@export_range(0, 23, 1) var current_hour: int = NORMAL_WAKE_HOUR
@export_range(0, 59, 1) var current_minute: int = 0

var _real_seconds_buffer := 0.0
var _pause_reasons: Dictionary = {}

func _process(delta: float) -> void:
	if is_time_paused():
		return

	_real_seconds_buffer += delta

	while _real_seconds_buffer >= REAL_SECONDS_PER_GAME_MINUTE:
		_real_seconds_buffer -= REAL_SECONDS_PER_GAME_MINUTE
		_advance_one_minute()

func advance_days(day_count: int = 1) -> bool:
	if day_count < 1:
		push_error("Die Anzahl der Tage muss mindestens 1 betragen.")
		return false

	for _day_index in range(day_count):
		_advance_one_day()

	return true

func set_date(new_year: int, new_month: Month, new_day: int) -> bool:
	if new_year < 1:
		push_error("Das Jahr muss mindestens 1 betragen.")
		return false

	if new_month < Month.SPRING or new_month > Month.WINTER:
		push_error("Der angegebene Monat ist ungültig.")
		return false

	if new_day < 1 or new_day > DAYS_PER_MONTH:
		push_error("Der Tag muss zwischen 1 und %d liegen." % DAYS_PER_MONTH)
		return false

	current_year = new_year
	current_month = new_month
	current_day = new_day

	year_changed.emit(current_year)
	month_changed.emit(current_month)
	day_changed.emit(current_day)
	date_changed.emit(current_year, current_month, current_day)
	return true

func set_time(new_hour: int, new_minute: int) -> bool:
	if new_hour < 0 or new_hour > 23:
		push_error("Die Stunde muss zwischen 0 und 23 liegen.")
		return false

	if new_minute < 0 or new_minute > 59:
		push_error("Die Minute muss zwischen 0 und 59 liegen.")
		return false

	current_hour = new_hour
	current_minute = new_minute
	_real_seconds_buffer = 0.0
	time_changed.emit(current_hour, current_minute)
	return true

func sleep_normally() -> void:
	_start_next_day(false)

func advance_game_minutes(minute_count: int = 1) -> bool:
	if minute_count < 1:
		push_error("Die Anzahl der Spielminuten muss mindestens 1 betragen.")
		return false

	for _minute_index in range(minute_count):
		_advance_one_minute()

	return true

func pause_time(reason: StringName) -> void:
	if reason == &"":
		push_error("Zum Pausieren der Zeit wird ein Grund benötigt.")
		return

	var was_paused := is_time_paused()
	_pause_reasons[reason] = true

	if not was_paused:
		time_pause_changed.emit(true)

func resume_time(reason: StringName) -> void:
	var was_paused := is_time_paused()
	_pause_reasons.erase(reason)

	if was_paused and not is_time_paused():
		time_pause_changed.emit(false)

func is_time_paused() -> bool:
	return not _pause_reasons.is_empty()

func reset_calendar() -> void:
	set_date(1, Month.SPRING, 1)
	set_time(NORMAL_WAKE_HOUR, 0)
	_pause_reasons.clear()
	time_pause_changed.emit(false)

func get_month_name() -> String:
	return MONTH_NAMES[current_month]

func get_date_text() -> String:
	return "Tag %d, %s, Jahr %d" % [
		current_day,
		get_month_name(),
		current_year,
	]

func get_time_text() -> String:
	return "%02d:%02d Uhr" % [current_hour, current_minute]

func get_date_data() -> Dictionary:
	return {
		"year": current_year,
		"month": current_month,
		"day": current_day,
		"hour": current_hour,
		"minute": current_minute,
	}

func _advance_one_minute() -> void:
	current_minute += 1

	if current_minute >= 60:
		current_minute = 0
		current_hour = (current_hour + 1) % 24

	time_changed.emit(current_hour, current_minute)

	if current_hour == FORCED_SLEEP_HOUR and current_minute == 0:
		_start_next_day(true)

func _start_next_day(was_forced_sleep: bool) -> void:
	var wake_hour := FORCED_WAKE_HOUR if was_forced_sleep else NORMAL_WAKE_HOUR

	if was_forced_sleep:
		forced_sleep.emit(FORCED_SLEEP_ENERGY_PENALTY_PERCENT)

	_advance_one_day()
	current_hour = wake_hour
	current_minute = 0
	_real_seconds_buffer = 0.0

	time_changed.emit(current_hour, current_minute)
	day_started.emit(
		current_year,
		current_month,
		current_day,
		wake_hour,
		was_forced_sleep
	)

func _advance_one_day() -> void:
	var previous_month := current_month
	var previous_year := current_year

	current_day += 1

	if current_day > DAYS_PER_MONTH:
		current_day = 1

		match current_month:
			Month.SPRING:
				current_month = Month.SUMMER
			Month.SUMMER:
				current_month = Month.AUTUMN
			Month.AUTUMN:
				current_month = Month.WINTER
			Month.WINTER:
				current_month = Month.SPRING
				current_year += 1

	if current_year != previous_year:
		year_changed.emit(current_year)

	if current_month != previous_month:
		month_changed.emit(current_month)

	day_changed.emit(current_day)
	date_changed.emit(current_year, current_month, current_day)
