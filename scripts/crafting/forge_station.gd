class_name ForgeStation
extends Interactable

## Schaltet die Schmiede auf der Testfläche frei, obwohl das spätere Hof-Bausystem noch nicht existiert.
@export var unlock_for_testing: bool = false

var _forge_system: ForgeSystem
var _forge_ui: ForgeUI

func _ready() -> void:
	super._ready()
	_forge_system = get_tree().get_first_node_in_group(&"forge_system") as ForgeSystem
	_forge_ui = get_tree().get_first_node_in_group(&"forge_ui") as ForgeUI
	if _forge_system == null or _forge_ui == null:
		push_error("ForgeStation findet Schmiedesystem oder Schmiedemenü nicht.")
		return
	if unlock_for_testing:
		_forge_system.unlock_station()

func interact(interactor: Node2D) -> bool:
	if not super.interact(interactor):
		return false
	return _forge_ui.open_menu()
