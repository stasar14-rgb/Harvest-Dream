class_name HarvestableResource
extends Node2D

signal state_changed
signal depleted(resource: HarvestableResource)
signal respawned(resource: HarvestableResource)

## Eindeutige ID dieses einzelnen Vorkommens innerhalb des Areals.
@export var resource_instance_id: StringName = &""
## Austauschbare Daten mit Trefferzahl, Beute und Wiedererscheinungszeit.
@export var resource_data: HarvestableResourceData

var current_hits: int = 0
var remaining_respawn_days: int = 0
var is_depleted: bool = false

func can_be_hit_with(tool: ToolData) -> bool:
	return (
		not is_depleted
		and resource_data != null
		and tool != null
		and tool.tool_type == resource_data.required_tool_type
	)

func will_deplete_with(tool: ToolData) -> bool:
	if not can_be_hit_with(tool):
		return false
	return current_hits + 1 >= resource_data.get_required_hits(tool)

func apply_hit(tool: ToolData) -> bool:
	if not can_be_hit_with(tool):
		return false

	current_hits += 1
	if current_hits >= resource_data.get_required_hits(tool):
		is_depleted = true
		remaining_respawn_days = resource_data.respawn_days
		depleted.emit(self)
	state_changed.emit()
	queue_redraw()
	return true

func advance_respawn_day() -> void:
	if not is_depleted:
		return
	remaining_respawn_days = maxi(remaining_respawn_days - 1, 0)
	if remaining_respawn_days == 0:
		is_depleted = false
		current_hits = 0
		respawned.emit(self)
	state_changed.emit()
	queue_redraw()

func get_state_data() -> Dictionary:
	return {
		"resource_instance_id": resource_instance_id,
		"current_hits": current_hits,
		"remaining_respawn_days": remaining_respawn_days,
		"is_depleted": is_depleted,
	}

func load_state_data(data: Dictionary) -> void:
	current_hits = maxi(int(data.get("current_hits", 0)), 0)
	remaining_respawn_days = maxi(int(data.get("remaining_respawn_days", 0)), 0)
	is_depleted = bool(data.get("is_depleted", false))
	queue_redraw()

func _ready() -> void:
	if resource_instance_id == &"":
		push_error("Ein Ressourcenvorkommen besitzt keine Instanz-ID.")
	if resource_data == null or not resource_data.is_valid_definition():
		push_error("Ressourcenvorkommen '%s' besitzt keine gültigen Daten." % resource_instance_id)
	queue_redraw()

func _draw() -> void:
	if is_depleted or resource_data == null:
		return
	if resource_data.texture != null:
		draw_texture(resource_data.texture, -resource_data.texture.get_size() * 0.5)
		return
	var size := resource_data.placeholder_size
	var hit_progress := clampf(float(current_hits) / float(resource_data.copper_required_hits), 0.0, 1.0)
	var display_color := resource_data.placeholder_color.darkened(hit_progress * 0.35)
	draw_rect(Rect2(-size * 0.5, size), display_color, true)
