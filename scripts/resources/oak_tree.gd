class_name OakTree
extends HarvestableResource

## Vollständiger, platzierbarer Eichenbaum mit Wachstum, Trefferschütteln und Fallanimation.

var _is_growing := false

@onready var tree_sprite: AnimatedSprite2D = $TreeSprite
@onready var trunk_collision: CollisionShape2D = $TrunkBody/CollisionShape2D

func _ready() -> void:
	super()
	state_changed.connect(_on_tree_state_changed)
	depleted.connect(_on_tree_depleted)
	respawned.connect(_on_tree_respawned)
	tree_sprite.animation_finished.connect(_on_animation_finished)
	_sync_visual_state()

func _draw() -> void:
	# Die Eiche nutzt AnimatedSprite2D; die Platzhalterdarstellung der Basisklasse
	# darf deshalb nicht zusätzlich hinter dem Baum gezeichnet werden.
	pass

func load_state_data(data: Dictionary) -> void:
	super(data)
	if is_node_ready():
		_sync_visual_state()

func play_growth_animation() -> void:
	_is_growing = true
	tree_sprite.visible = true
	tree_sprite.position = Vector2(-32.0, -96.0)
	tree_sprite.play(&"grow")
	_set_collision_enabled(true)

func _sync_visual_state() -> void:
	_is_growing = false
	if is_depleted:
		tree_sprite.stop()
		tree_sprite.visible = false
		_set_collision_enabled(false)
		return
	_show_idle_tree()
	_set_collision_enabled(true)

func _show_idle_tree() -> void:
	_is_growing = false
	tree_sprite.visible = true
	tree_sprite.position = Vector2(-32.0, -96.0)
	tree_sprite.play(&"idle")

func _on_tree_state_changed() -> void:
	if is_depleted or _is_growing:
		return
	tree_sprite.visible = true
	tree_sprite.position = Vector2(-32.0, -96.0)
	tree_sprite.play(&"hit_shake")

func _on_tree_depleted(_resource: HarvestableResource) -> void:
	_is_growing = false
	_set_collision_enabled(false)
	tree_sprite.visible = true
	# Die Fallframes sind 128 Pixel breit. Diese Position hält den Stammfuß
	# beim Wechsel von 64×96 auf 128×96 an derselben Weltposition.
	tree_sprite.position = Vector2(-36.0, -96.0)
	tree_sprite.play(&"fall_right")

func _on_tree_respawned(_resource: HarvestableResource) -> void:
	play_growth_animation()

func _on_animation_finished() -> void:
	match tree_sprite.animation:
		&"hit_shake":
			_show_idle_tree()
		&"fall_right":
			tree_sprite.visible = false
		&"grow":
			_show_idle_tree()

func _set_collision_enabled(enabled: bool) -> void:
	trunk_collision.set_deferred("disabled", not enabled)
