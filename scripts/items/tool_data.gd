class_name ToolData
extends ItemData

enum ToolType {
	AXE,
	PICKAXE,
	HOE,
	WATERING_CAN,
	SHOVEL,
	SICKLE,
}

enum MaterialTier {
	NONE,
	COPPER,
	BRONZE,
	IRON,
	STEEL,
}

const MAX_CHARGE_LEVEL := 3
const CHARGE_AREA_SIZES: Array[int] = [1, 3, 6, 9]
const CHARGE_ENERGY_COSTS: Array[float] = [5.0, 7.5, 10.0, 12.5]

## Art des Werkzeugs. Sie bestimmt, welche spätere Werkzeugaktion ausgelöst werden darf.
@export var tool_type: ToolType = ToolType.AXE
## Materialstufe des Werkzeugs. Sichel und Schaufel verwenden „Keine“.
@export var material_tier: MaterialTier = MaterialTier.NONE
## Grundenergie pro Einsatz oder Schlag. Bei aufladbaren Werkzeugen gelten stattdessen die Kosten der Aufladestufe.
@export_range(0.0, 100.0, 0.5) var base_energy_cost: float = 5.0
## Anzahl der Schläge, die gegenüber der Grund-Schlagzahl einer Ressource eingespart werden.
@export_range(0, 99, 1) var hit_reduction: int = 0
## Legt fest, ob das Werkzeug durch Halten der linken Maustaste aufgeladen werden kann.
@export var uses_charge: bool = false
## Höchste freigeschaltete Aufladestufe: 0 = 1 Feld, 1 = 3 Felder, 2 = 6 Felder, 3 = 9 Felder.
@export_range(0, MAX_CHARGE_LEVEL, 1) var max_charge_level: int = 0
## Sekunden, die für jede weitere Aufladestufe gehalten werden müssen.
@export_range(0.1, 10.0, 0.1) var charge_step_seconds: float = 1.0
## Spätere feste Verringerung der Energiekosten bei Hacke und Gießkanne. Der genaue Wert wird erst bei der Balance festgelegt.
@export_range(0.0, 100.0, 0.5) var charge_energy_reduction: float = 0.0

func get_charge_level(held_seconds: float) -> int:
	if not uses_charge:
		return 0

	var requested_level: int = floori(maxf(held_seconds, 0.0) / charge_step_seconds)
	return clampi(requested_level, 0, max_charge_level)

func get_charge_area_size(charge_level: int) -> int:
	var valid_level := clampi(charge_level, 0, MAX_CHARGE_LEVEL)
	return CHARGE_AREA_SIZES[valid_level]

func get_energy_cost(charge_level: int = 0) -> float:
	if not uses_charge:
		return base_energy_cost

	var valid_level := clampi(charge_level, 0, max_charge_level)
	return maxf(CHARGE_ENERGY_COSTS[valid_level] - charge_energy_reduction, 0.0)

func get_required_hits(resource_base_hits: int) -> int:
	return maxi(resource_base_hits - hit_reduction, 1)

func is_valid_definition() -> bool:
	if not super.is_valid_definition():
		return false

	if category != Category.TOOL:
		push_error("Werkzeug '%s' verwendet nicht die Gegenstandskategorie TOOL." % item_id)
		return false

	if uses_charge and tool_type != ToolType.HOE and tool_type != ToolType.WATERING_CAN:
		push_error("Nur Hacke und Gießkanne dürfen das Aufladesystem verwenden: %s" % item_id)
		return false

	if not uses_charge and max_charge_level != 0:
		push_error("Werkzeug '%s' besitzt ohne Aufladesystem eine Aufladestufe." % item_id)
		return false

	return true
