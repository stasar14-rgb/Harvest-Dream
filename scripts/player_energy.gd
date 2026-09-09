class_name PlayerEnergy
extends Node

signal energy_changed(current_energy: float, maximum_energy: float)
signal maximum_energy_changed(maximum_energy: float)
signal energy_depleted
signal warm_clothing_changed(is_active: bool)

const STARTING_MAXIMUM_ENERGY := 100.0
const WINTER_EXTRA_COST_PERCENT := 25.0

@export var calendar_path: NodePath = ^"../GameCalendar"
@export var season_system_path: NodePath = ^"../SeasonSystem"
@export var maximum_energy: float = STARTING_MAXIMUM_ENERGY
@export var current_energy: float = STARTING_MAXIMUM_ENERGY

@onready var _calendar := get_node_or_null(calendar_path) as GameCalendar
@onready var _season_system := get_node_or_null(season_system_path) as SeasonSystem

var _warm_clothing_active := false

func _ready() -> void:
	if _calendar == null:
		push_error("PlayerEnergy findet keinen GameCalendar.")
		return

	if _season_system == null:
		push_error("PlayerEnergy findet kein SeasonSystem.")
		return

	maximum_energy = maxf(maximum_energy, 1.0)
	current_energy = clampf(current_energy, 0.0, maximum_energy)
	_calendar.day_started.connect(_on_day_started)
	_emit_energy_changed()

func can_afford(base_cost: float) -> bool:
	if base_cost < 0.0:
		return false

	return current_energy >= get_final_energy_cost(base_cost)

func consume_energy(base_cost: float) -> bool:
	if base_cost < 0.0:
		push_error("Energiekosten dürfen nicht negativ sein.")
		return false

	var final_cost := get_final_energy_cost(base_cost)
	if current_energy < final_cost:
		return false

	current_energy = maxf(current_energy - final_cost, 0.0)
	_emit_energy_changed()

	if is_zero_approx(current_energy):
		energy_depleted.emit()

	return true

func restore_energy(amount: float) -> bool:
	if amount < 0.0:
		push_error("Wiederhergestellte Energie darf nicht negativ sein.")
		return false

	current_energy = minf(current_energy + amount, maximum_energy)
	_emit_energy_changed()
	return true

func restore_to_maximum() -> void:
	current_energy = maximum_energy
	_emit_energy_changed()

func set_maximum_energy(new_maximum: float, refill_to_maximum: bool = false) -> bool:
	if new_maximum < 1.0:
		push_error("Die maximale Energie muss mindestens 1 betragen.")
		return false

	maximum_energy = new_maximum

	if refill_to_maximum:
		current_energy = maximum_energy
	else:
		current_energy = minf(current_energy, maximum_energy)

	maximum_energy_changed.emit(maximum_energy)
	_emit_energy_changed()
	return true

func set_warm_clothing_active(is_active: bool) -> void:
	if _warm_clothing_active == is_active:
		return

	_warm_clothing_active = is_active
	warm_clothing_changed.emit(_warm_clothing_active)

func has_warm_clothing() -> bool:
	return _warm_clothing_active

func get_final_energy_cost(base_cost: float) -> float:
	if base_cost <= 0.0:
		return 0.0

	if _season_system.requires_warm_clothing() and not _warm_clothing_active:
		return base_cost * (1.0 + WINTER_EXTRA_COST_PERCENT / 100.0)

	return base_cost

func reset_energy() -> void:
	maximum_energy = STARTING_MAXIMUM_ENERGY
	current_energy = STARTING_MAXIMUM_ENERGY
	_warm_clothing_active = false
	maximum_energy_changed.emit(maximum_energy)
	warm_clothing_changed.emit(_warm_clothing_active)
	_emit_energy_changed()

func get_energy_data() -> Dictionary:
	return {
		"maximum_energy": maximum_energy,
		"current_energy": current_energy,
		"warm_clothing_active": _warm_clothing_active,
	}

func _on_day_started(
	_year: int,
	_month: int,
	_day: int,
	_wake_hour: int,
	was_forced_sleep: bool
) -> void:
	if was_forced_sleep:
		current_energy = maximum_energy * (1.0 - GameCalendar.FORCED_SLEEP_ENERGY_PENALTY_PERCENT / 100.0)
	else:
		current_energy = maximum_energy

	_emit_energy_changed()

func _emit_energy_changed() -> void:
	energy_changed.emit(current_energy, maximum_energy)
