class_name HarvestableResourceData
extends Resource

## Eindeutige interne ID dieser Ressourcenart.
@export var resource_id: StringName = &""
## Sichtbarer Name der Ressource für Meldungen und spätere Informationsfenster.
@export var display_name: String = ""
## Werkzeugart, mit der diese Ressource abgebaut werden kann.
@export var required_tool_type: ToolData.ToolType = ToolData.ToolType.AXE
## Benötigte Schläge mit einem Kupferwerkzeug. Höhere Werkzeugstufen ziehen ihre Trefferverringerung davon ab.
@export_range(1, 999, 1) var copper_required_hits: int = 1
## Gegenstands-ID der Ressource, die nach dem letzten Schlag ausgegeben wird.
@export var drop_item_id: StringName = &""
## Feste Anzahl der Gegenstände, die dieses Vorkommen ausgibt.
@export_range(1, 999, 1) var drop_amount: int = 1
## Anzahl vollständiger Spieltage bis zum erneuten Erscheinen nach dem Abbau.
@export_range(1, 999, 1) var respawn_days: int = 3
## Später austauschbare Grafik der Ressource.
@export var texture: Texture2D
## Größe des vorläufigen Platzhalters, solange keine Grafik eingetragen ist.
@export var placeholder_size: Vector2 = Vector2(28.0, 28.0)
## Farbe des vorläufigen Platzhalters, solange keine Grafik eingetragen ist.
@export var placeholder_color: Color = Color(0.45, 0.45, 0.45, 1.0)

func get_required_hits(tool: ToolData) -> int:
	if tool == null:
		return copper_required_hits
	return tool.get_required_hits(copper_required_hits)

func is_valid_definition() -> bool:
	if resource_id == &"" or display_name.is_empty():
		push_error("Eine Ressourcendefinition benötigt ID und Namen.")
		return false
	if drop_item_id == &"":
		push_error("Ressource '%s' besitzt keinen Beutegegenstand." % resource_id)
		return false
	if required_tool_type != ToolData.ToolType.AXE and required_tool_type != ToolData.ToolType.PICKAXE:
		push_error("Ressource '%s' benötigt eine Axt oder Spitzhacke." % resource_id)
		return false
	if copper_required_hits < 1 or drop_amount < 1 or respawn_days < 1:
		push_error("Ressource '%s' besitzt ungültige Abbau- oder Wiedererscheinungswerte." % resource_id)
		return false
	return true
