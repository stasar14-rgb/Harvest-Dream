class_name GroundItemSystem
extends Node2D

signal ground_item_created(item: GroundItem)
signal ground_item_changed(item: GroundItem)
signal ground_item_picked_up(item_id: StringName, amount: int)
signal ground_items_expired

## Entfernung in Pixeln, aus der Bodenbeute automatisch aufgenommen wird.
@export_range(1.0, 256.0, 1.0) var pickup_radius: float = 48.0
## Maximale Entfernung in Pixeln, bei der gleiche Gegenstände automatisch zusammengelegt werden.
@export_range(1.0, 256.0, 1.0) var merge_radius: float = 32.0
## Größe der vorläufigen Darstellung für Gegenstände ohne Icon.
@export var placeholder_size: Vector2 = Vector2(16.0, 16.0)
## Farbe der vorläufigen Darstellung für Gegenstände ohne Icon.
@export var placeholder_color: Color = Color(0.95, 0.82, 0.28, 1.0)

var _ground_items: Array[GroundItem] = []
var _player: Node2D
var _inventory_system: InventorySystem
var _item_database: ItemDatabase
var _calendar: GameCalendar
var _inventory_ui: InventoryUI
var _full_inventory_message_cooldown: float = 0.0

func _ready() -> void:
	_player = get_tree().get_first_node_in_group(&"player") as Node2D
	_inventory_system = get_tree().get_first_node_in_group(&"inventory_system") as InventorySystem
	_item_database = get_tree().get_first_node_in_group(&"item_database") as ItemDatabase
	_calendar = get_tree().get_first_node_in_group(&"game_calendar") as GameCalendar
	_inventory_ui = get_tree().get_first_node_in_group(&"inventory_ui") as InventoryUI

	if _player == null or _inventory_system == null or _item_database == null or _calendar == null:
		push_error("GroundItemSystem findet Spieler, Inventar, ItemDatabase oder Kalender nicht.")
		return

	_calendar.day_started.connect(_on_day_started)

func _physics_process(delta: float) -> void:
	_full_inventory_message_cooldown = maxf(_full_inventory_message_cooldown - delta, 0.0)
	var items_snapshot: Array[GroundItem] = _ground_items.duplicate()
	for ground_item in items_snapshot:
		if not is_instance_valid(ground_item):
			_ground_items.erase(ground_item)
			continue
		if ground_item.global_position.distance_to(_player.global_position) <= pickup_radius:
			_try_pick_up(ground_item)

func can_spawn_item(item_id: StringName, amount: int) -> bool:
	return amount > 0 and _item_database != null and _item_database.has_item(item_id)

func spawn_item(world_position: Vector2, item_id: StringName, amount: int) -> bool:
	if not can_spawn_item(item_id, amount):
		push_error("Bodenbeute '%s' mit Menge %d ist ungültig." % [item_id, amount])
		return false

	var item_data := _item_database.get_item(item_id)
	var remaining_amount := amount
	while remaining_amount > 0:
		var nearby_stack := _find_nearby_stack(world_position, item_id)
		if nearby_stack != null:
			remaining_amount = nearby_stack.add_amount(remaining_amount)
			ground_item_changed.emit(nearby_stack)
			continue

		var new_ground_item := GroundItem.new()
		add_child(new_ground_item)
		new_ground_item.global_position = world_position
		var stack_amount := mini(remaining_amount, item_data.get_stack_limit())
		new_ground_item.setup(item_data, stack_amount, placeholder_size, placeholder_color)
		new_ground_item.emptied.connect(_on_ground_item_emptied)
		_ground_items.append(new_ground_item)
		remaining_amount -= stack_amount
		ground_item_created.emit(new_ground_item)
	return true

func get_ground_item_data() -> Array[Dictionary]:
	var data: Array[Dictionary] = []
	for ground_item in _ground_items:
		if is_instance_valid(ground_item) and ground_item.amount > 0:
			data.append(ground_item.get_save_data())
	return data

func load_ground_item_data(data: Array[Dictionary]) -> void:
	_clear_ground_items()
	for entry in data:
		var item_id := StringName(entry.get("item_id", ""))
		var amount := maxi(int(entry.get("amount", 0)), 0)
		var world_position := Vector2(
			float(entry.get("x", 0.0)),
			float(entry.get("y", 0.0))
		)
		if amount > 0:
			spawn_item(world_position, item_id, amount)

func _try_pick_up(ground_item: GroundItem) -> void:
	if ground_item.item_data == null or ground_item.amount <= 0:
		return
	var free_capacity := _inventory_system.get_free_capacity_for(ground_item.item_data.item_id)
	var pickup_amount := mini(ground_item.amount, free_capacity)
	if pickup_amount <= 0:
		_show_inventory_full_message()
		return
	if not _inventory_system.try_add_item(ground_item.item_data.item_id, pickup_amount):
		return
	ground_item.remove_amount(pickup_amount)
	ground_item_picked_up.emit(ground_item.item_data.item_id, pickup_amount)
	if ground_item.amount > 0:
		ground_item_changed.emit(ground_item)

func _show_inventory_full_message() -> void:
	if _inventory_ui == null or _full_inventory_message_cooldown > 0.0:
		return
	_inventory_ui.show_message("Inventar voll – die Beute bleibt auf dem Boden.")
	_full_inventory_message_cooldown = 2.5

func _find_nearby_stack(world_position: Vector2, item_id: StringName) -> GroundItem:
	for ground_item in _ground_items:
		if not is_instance_valid(ground_item) or ground_item.item_data == null:
			continue
		if ground_item.item_data.item_id != item_id or ground_item.get_free_stack_space() <= 0:
			continue
		if ground_item.global_position.distance_to(world_position) <= merge_radius:
			return ground_item
	return null

func _on_ground_item_emptied(ground_item: GroundItem) -> void:
	_ground_items.erase(ground_item)
	ground_item.queue_free()

func _on_day_started(
	_year: int,
	_month: int,
	_day: int,
	_wake_hour: int,
	_was_forced_sleep: bool
) -> void:
	_clear_ground_items()
	ground_items_expired.emit()

func _clear_ground_items() -> void:
	for ground_item in _ground_items:
		if is_instance_valid(ground_item):
			ground_item.queue_free()
	_ground_items.clear()
