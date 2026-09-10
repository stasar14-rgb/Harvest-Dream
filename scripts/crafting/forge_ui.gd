class_name ForgeUI
extends CanvasLayer

const FORGE_PAUSE_REASON: StringName = &"forge_menu"

@onready var root: Control = $Root
@onready var recipe_list: VBoxContainer = $Root/MainPanel/Margin/MainVBox/Content/LeftColumn/RecipePanel/RecipeMargin/RecipeVBox/RecipeScroll/RecipeList
@onready var detail_icon: TextureRect = $Root/MainPanel/Margin/MainVBox/Content/RightColumn/DetailPanel/DetailMargin/DetailVBox/TopRow/DetailIcon
@onready var detail_name: Label = $Root/MainPanel/Margin/MainVBox/Content/RightColumn/DetailPanel/DetailMargin/DetailVBox/TopRow/DetailName
@onready var ingredient_list: VBoxContainer = $Root/MainPanel/Margin/MainVBox/Content/RightColumn/DetailPanel/DetailMargin/DetailVBox/IngredientList
@onready var craft_one_button: Button = $Root/MainPanel/Margin/MainVBox/Content/RightColumn/DetailPanel/DetailMargin/DetailVBox/QuantityButtons/CraftOne
@onready var craft_ten_button: Button = $Root/MainPanel/Margin/MainVBox/Content/RightColumn/DetailPanel/DetailMargin/DetailVBox/QuantityButtons/CraftTen
@onready var craft_max_button: Button = $Root/MainPanel/Margin/MainVBox/Content/RightColumn/DetailPanel/DetailMargin/DetailVBox/QuantityButtons/CraftMax
@onready var storage_grid: GridContainer = $Root/MainPanel/Margin/MainVBox/Content/RightColumn/StoragePanel/StorageMargin/StorageVBox/StorageGrid
@onready var current_name: Label = $Root/MainPanel/Margin/MainVBox/Content/LeftColumn/CurrentPanel/CurrentMargin/CurrentVBox/CurrentName
@onready var progress_bar: ProgressBar = $Root/MainPanel/Margin/MainVBox/Content/LeftColumn/CurrentPanel/CurrentMargin/CurrentVBox/ProgressRow/ProgressBar
@onready var progress_count: Label = $Root/MainPanel/Margin/MainVBox/Content/LeftColumn/CurrentPanel/CurrentMargin/CurrentVBox/ProgressRow/ProgressCount
@onready var cancel_button: Button = $Root/MainPanel/Margin/MainVBox/Content/LeftColumn/CurrentPanel/CurrentMargin/CurrentVBox/CancelButton
@onready var close_button: Button = $Root/MainPanel/Margin/MainVBox/Header/CloseButton
@onready var message_label: Label = $Root/MessageLabel

var _forge_system: ForgeSystem
var _item_database: ItemDatabase
var _calendar: GameCalendar
var _selected_recipe_id: StringName = &""
var _storage_controls: Array[ForgeStorageSlotControl] = []

func _ready() -> void:
	_forge_system = get_tree().get_first_node_in_group(&"forge_system") as ForgeSystem
	_item_database = get_tree().get_first_node_in_group(&"item_database") as ItemDatabase
	_calendar = get_tree().get_first_node_in_group(&"game_calendar") as GameCalendar
	if _forge_system == null or _item_database == null or _calendar == null:
		push_error("ForgeUI findet Schmiede-, Gegenstands- oder Kalendersystem nicht.")
		return

	_forge_system.storage_changed.connect(_refresh_all)
	_forge_system.queue_changed.connect(_refresh_all)
	_forge_system.progress_changed.connect(_on_progress_changed)
	_forge_system.operation_rejected.connect(_show_message)
	craft_one_button.pressed.connect(_on_craft_one_pressed)
	craft_ten_button.pressed.connect(_on_craft_ten_pressed)
	craft_max_button.pressed.connect(_on_craft_max_pressed)
	cancel_button.pressed.connect(_on_cancel_pressed)
	close_button.pressed.connect(close_menu)
	_build_recipe_list()
	_build_storage_grid()
	_select_first_recipe()
	_refresh_all()
	root.visible = false
	message_label.visible = false

func _unhandled_input(event: InputEvent) -> void:
	if root.visible and event.is_action_pressed(&"ui_cancel"):
		close_menu()
		get_viewport().set_input_as_handled()

func open_menu() -> bool:
	if not _forge_system.station_unlocked:
		_show_message("Die Schmiede wurde noch nicht gebaut.")
		return false
	root.visible = true
	_calendar.pause_time(FORGE_PAUSE_REASON)
	_refresh_all()
	return true

func close_menu() -> void:
	if not root.visible:
		return
	root.visible = false
	_calendar.resume_time(FORGE_PAUSE_REASON)

func is_menu_open() -> bool:
	return root.visible

func _build_recipe_list() -> void:
	for child in recipe_list.get_children():
		child.queue_free()
	for recipe in _forge_system.get_recipes():
		var button := Button.new()
		button.custom_minimum_size = Vector2(0.0, 68.0)
		button.focus_mode = Control.FOCUS_NONE
		button.toggle_mode = true
		var row := HBoxContainer.new()
		row.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		row.offset_left = 8.0
		row.offset_right = -8.0
		row.mouse_filter = Control.MOUSE_FILTER_IGNORE
		var icon := TextureRect.new()
		icon.custom_minimum_size = Vector2(48.0, 48.0)
		icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		var output_item := _item_database.get_item(recipe.output_item_id)
		icon.texture = output_item.icon if output_item != null else null
		row.add_child(icon)
		var name_label := Label.new()
		name_label.text = recipe.display_name
		name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row.add_child(name_label)
		var status_label := Label.new()
		status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		status_label.custom_minimum_size = Vector2(170.0, 0.0)
		row.add_child(status_label)
		button.add_child(row)
		button.set_meta(&"recipe_id", recipe.recipe_id)
		button.set_meta(&"status_label", status_label)
		button.pressed.connect(_on_recipe_pressed.bind(recipe.recipe_id))
		recipe_list.add_child(button)

func _build_storage_grid() -> void:
	for child in storage_grid.get_children():
		child.queue_free()
	_storage_controls.clear()
	for slot_index in _forge_system.storage_capacity:
		var control := ForgeStorageSlotControl.new()
		control.setup(_forge_system, _item_database, slot_index)
		storage_grid.add_child(control)
		_storage_controls.append(control)

func _select_first_recipe() -> void:
	var recipes := _forge_system.get_recipes()
	if not recipes.is_empty():
		_selected_recipe_id = recipes[0].recipe_id

func _refresh_all() -> void:
	_refresh_recipe_list()
	_refresh_recipe_details()
	_refresh_storage()
	_refresh_current_batch()

func _refresh_recipe_list() -> void:
	for child in recipe_list.get_children():
		var button := child as Button
		if button == null:
			continue
		var recipe_id := StringName(button.get_meta(&"recipe_id", &""))
		var recipe := _forge_system.get_recipe(recipe_id)
		if recipe == null:
			continue
		var craftable := _forge_system.get_max_craftable(recipe_id) > 0
		var status_label := button.get_meta(&"status_label") as Label
		if status_label != null:
			status_label.text = "Herstellbar" if craftable else "Fehlendes Material"
			status_label.modulate = Color(0.25, 0.9, 0.4) if craftable else Color(1.0, 0.3, 0.3)
		button.button_pressed = recipe_id == _selected_recipe_id

func _refresh_recipe_details() -> void:
	var recipe := _forge_system.get_recipe(_selected_recipe_id)
	if recipe == null:
		detail_name.text = "Kein Rezept ausgewählt"
		return
	var output_item := _item_database.get_item(recipe.output_item_id)
	detail_name.text = recipe.display_name
	detail_icon.texture = output_item.icon if output_item != null else null
	for child in ingredient_list.get_children():
		child.queue_free()
	var title := Label.new()
	title.text = "Benötigte Materialien:"
	ingredient_list.add_child(title)
	_add_ingredient_row("", "Benötigt", "Besitz", true)
	for index in recipe.ingredient_item_ids.size():
		var item_id := recipe.ingredient_item_ids[index]
		var item := _item_database.get_item(item_id)
		var needed := recipe.ingredient_amounts[index]
		var owned := _forge_system.get_owned_available_amount(item_id)
		_add_ingredient_row(
			item.display_name if item != null else String(item_id),
			"%dx" % needed,
			"%dx" % owned,
			owned >= needed
		)
	var maximum := _forge_system.get_max_craftable(recipe.recipe_id)
	craft_one_button.disabled = maximum < 1
	craft_ten_button.disabled = maximum < 10
	craft_max_button.disabled = maximum < 1
	craft_max_button.text = "Max (%d)" % maximum

func _add_ingredient_row(
	item_name: String,
	needed_text: String,
	owned_text: String,
	has_enough: bool
) -> void:
	var row := HBoxContainer.new()
	var name_label := Label.new()
	name_label.text = item_name
	name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(name_label)
	var needed_label := Label.new()
	needed_label.text = needed_text
	needed_label.custom_minimum_size = Vector2(100.0, 0.0)
	needed_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	row.add_child(needed_label)
	var owned_label := Label.new()
	owned_label.text = owned_text
	owned_label.custom_minimum_size = Vector2(100.0, 0.0)
	owned_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	owned_label.modulate = Color.WHITE if has_enough else Color(1.0, 0.35, 0.35)
	row.add_child(owned_label)
	ingredient_list.add_child(row)

func _refresh_storage() -> void:
	for control in _storage_controls:
		control.update_slot()

func _refresh_current_batch() -> void:
	var recipe := _forge_system.get_current_recipe()
	if recipe == null:
		current_name.text = "Kein Auftrag"
		progress_count.text = "0/0"
		progress_bar.value = 0.0
		cancel_button.disabled = true
		return
	current_name.text = recipe.display_name
	progress_count.text = "%d/%d" % [
		_forge_system.get_current_completed_amount(),
		_forge_system.get_current_total_amount(),
	]
	progress_bar.value = _forge_system.get_progress_ratio() * 100.0
	cancel_button.disabled = false

func _on_progress_changed(progress_ratio: float) -> void:
	progress_bar.value = progress_ratio * 100.0

func _on_recipe_pressed(recipe_id: StringName) -> void:
	_selected_recipe_id = recipe_id
	_refresh_all()

func _on_craft_one_pressed() -> void:
	_forge_system.request_crafting(_selected_recipe_id, 1)

func _on_craft_ten_pressed() -> void:
	_forge_system.request_crafting(_selected_recipe_id, 10)

func _on_craft_max_pressed() -> void:
	var maximum := _forge_system.get_max_craftable(_selected_recipe_id)
	if maximum > 0:
		_forge_system.request_crafting(_selected_recipe_id, maximum)

func _on_cancel_pressed() -> void:
	_forge_system.cancel_current_batch()

func _show_message(message: String) -> void:
	message_label.text = message
	message_label.visible = true
	await get_tree().create_timer(2.5).timeout
	if message_label.text == message:
		message_label.visible = false
