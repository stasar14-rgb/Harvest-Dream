class_name SoilCellState
extends RefCounted

var watered := false
var days_without_plant := 0
var has_plant := false

func to_dictionary(cell: Vector2i) -> Dictionary:
	return {
		"x": cell.x,
		"y": cell.y,
		"watered": watered,
		"days_without_plant": days_without_plant,
		"has_plant": has_plant,
	}

static func from_dictionary(data: Dictionary) -> SoilCellState:
	var state := SoilCellState.new()
	state.watered = bool(data.get("watered", false))
	state.days_without_plant = maxi(int(data.get("days_without_plant", 0)), 0)
	state.has_plant = bool(data.get("has_plant", false))
	return state
