class_name SeasonSystem
extends Node

signal season_changed(season: int, season_name: String)
signal season_rules_changed(
	outdoor_plants_can_grow: bool,
	mushrooms_can_spawn: bool,
	winter_fruits_can_spawn: bool,
	warm_clothing_required: bool
)

@export var calendar_path: NodePath = ^"../GameCalendar"

@onready var _calendar := get_node_or_null(calendar_path) as GameCalendar

var current_season: int = GameCalendar.Month.SPRING

func _ready() -> void:
	if _calendar == null:
		push_error("Das SeasonSystem findet keinen GameCalendar.")
		return

	current_season = _calendar.current_month
	_calendar.month_changed.connect(_on_month_changed)
	_emit_season_state()

func get_season_name() -> String:
	return GameCalendar.MONTH_NAMES[current_season]

func is_winter() -> bool:
	return current_season == GameCalendar.Month.WINTER

func can_outdoor_plants_grow() -> bool:
	return not is_winter()

func can_mushrooms_spawn() -> bool:
	return not is_winter()

func can_winter_fruits_spawn() -> bool:
	return is_winter()

func requires_warm_clothing() -> bool:
	return is_winter()

func is_content_available(allowed_seasons: Array) -> bool:
	if allowed_seasons.is_empty():
		return true

	return allowed_seasons.has(current_season)

func _on_month_changed(month: int) -> void:
	current_season = month
	_emit_season_state()

func _emit_season_state() -> void:
	season_changed.emit(current_season, get_season_name())
	season_rules_changed.emit(
		can_outdoor_plants_grow(),
		can_mushrooms_spawn(),
		can_winter_fruits_spawn(),
		requires_warm_clothing()
	)
