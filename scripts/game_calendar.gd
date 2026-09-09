class_name GameCalendar
extends Node

signal day_changed(day: int)
signal month_changed(month: int)
signal year_changed(year: int)
signal date_changed(year: int, month: int, day: int)

enum Month {
	SPRING,
	SUMMER,
	AUTUMN,
	WINTER,
}

const DAYS_PER_MONTH := 28
const MONTHS_PER_YEAR := 4
const MONTH_NAMES: Array[String] = [
	"Frühling",
	"Sommer",
	"Herbst",
	"Winter",
]

@export_range(1, 28, 1) var current_day: int = 1
@export var current_month: Month = Month.SPRING
@export_range(1, 9999, 1) var current_year: int = 1

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

func reset_calendar() -> void:
	set_date(1, Month.SPRING, 1)

func get_month_name() -> String:
	return MONTH_NAMES[current_month]

func get_date_text() -> String:
	return "Tag %d, %s, Jahr %d" % [
		current_day,
		get_month_name(),
		current_year,
	]

func get_date_data() -> Dictionary:
	return {
		"year": current_year,
		"month": current_month,
		"day": current_day,
	}

func _advance_one_day() -> void:
	var previous_month := current_month
	var previous_year := current_year

	current_day += 1

	if current_day > DAYS_PER_MONTH:
		current_day = 1
		current_month = (current_month + 1) % MONTHS_PER_YEAR

		if current_month == Month.SPRING:
			current_year += 1

	if current_year != previous_year:
		year_changed.emit(current_year)

	if current_month != previous_month:
		month_changed.emit(current_month)

	day_changed.emit(current_day)
	date_changed.emit(current_year, current_month, current_day)
