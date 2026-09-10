class_name PlantState
extends RefCounted

var plant_data: PlantData
var grown_days: int = 0
var consecutive_dry_days: int = 0
var is_spoiled: bool = false
var harvest_amount: int = 1

func is_ready_for_harvest() -> bool:
	return plant_data != null and not is_spoiled and grown_days >= plant_data.growth_days

func to_dictionary(cell: Vector2i) -> Dictionary:
	return {
		"x": cell.x,
		"y": cell.y,
		"plant_id": plant_data.plant_id if plant_data != null else &"",
		"grown_days": grown_days,
		"consecutive_dry_days": consecutive_dry_days,
		"is_spoiled": is_spoiled,
		"harvest_amount": harvest_amount,
	}

static func from_dictionary(data: Dictionary, definition: PlantData) -> PlantState:
	var state := PlantState.new()
	state.plant_data = definition
	state.grown_days = maxi(int(data.get("grown_days", 0)), 0)
	state.consecutive_dry_days = maxi(int(data.get("consecutive_dry_days", 0)), 0)
	state.is_spoiled = bool(data.get("is_spoiled", false))
	state.harvest_amount = maxi(int(data.get("harvest_amount", 1)), 1)
	return state
