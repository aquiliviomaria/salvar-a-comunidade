extends Node

signal construction_built(structure_id: String, position: Vector3)
signal message_sent(text: String)

const STRUCTURES: Dictionary = {
	"house": {
		"name": "Casa",
		"icon": "home",
		"cost": {"wood": 4, "water": 1, "money": 40},
		"size": Vector3(4.0, 2.4, 3.4),
		"color": Color(0.72, 0.52, 0.31),
		"effect": "Aloja uma familia e melhora o bem-estar."
	},
	"chicken_coop": {
		"name": "Capoeira",
		"icon": "home",
		"cost": {"wood": 3, "food": 1, "money": 30},
		"size": Vector3(3.0, 1.8, 2.6),
		"color": Color(0.58, 0.38, 0.18),
		"effect": "Aloja galinhas e apoia alimentacao."
	},
	"corral": {
		"name": "Curral",
		"icon": "home",
		"cost": {"wood": 5, "water": 1, "money": 45},
		"size": Vector3(5.0, 1.4, 4.0),
		"color": Color(0.48, 0.32, 0.16),
		"effect": "Organiza bois e cabritos."
	},
	"warehouse": {
		"name": "Armazem",
		"icon": "inventory",
		"cost": {"wood": 6, "money": 70},
		"size": Vector3(5.0, 2.2, 4.0),
		"color": Color(0.46, 0.42, 0.32),
		"effect": "Guarda recursos da comunidade."
	},
	"fence": {
		"name": "Cerca",
		"icon": "hammer",
		"cost": {"wood": 2, "money": 15},
		"size": Vector3(4.0, 1.0, 0.35),
		"color": Color(0.52, 0.34, 0.18),
		"effect": "Protege areas e caminhos."
	},
	"water_point": {
		"name": "Ponto de agua",
		"icon": "water",
		"cost": {"wood": 2, "water": 2, "money": 55},
		"size": Vector3(2.6, 1.4, 2.6),
		"color": Color(0.22, 0.52, 0.78),
		"effect": "Melhora acesso a agua segura."
	}
}

var built_structures: Array = []


func get_structures() -> Array:
	var result: Array = []
	for structure_id: String in STRUCTURES.keys():
		var data: Dictionary = STRUCTURES[structure_id].duplicate(true)
		data["id"] = structure_id
		result.append(data)
	return result


func can_build(structure_id: String) -> Dictionary:
	if not STRUCTURES.has(structure_id):
		return {"ok": false, "message": "Estrutura desconhecida."}
	var cost: Dictionary = STRUCTURES[structure_id].get("cost", {})
	var missing: Array = []
	for key: String in cost.keys():
		var required: int = int(cost[key])
		var current: int = _get_resource_amount(key)
		if current < required:
			missing.append("%s %d/%d" % [key, current, required])
	if missing.size() > 0:
		return {"ok": false, "message": "Faltam recursos: %s" % ", ".join(missing)}
	return {"ok": true, "message": "Pode construir."}


func build(structure_id: String, position: Vector3) -> Dictionary:
	var validation: Dictionary = can_build(structure_id)
	if not bool(validation.get("ok", false)):
		return validation
	var cost: Dictionary = STRUCTURES[structure_id].get("cost", {})
	for key: String in cost.keys():
		_spend_resource(key, int(cost[key]))
	built_structures.append({"id": structure_id, "position": position})
	construction_built.emit(structure_id, position)
	var name: String = str(STRUCTURES[structure_id].get("name", "Estrutura"))
	message_sent.emit("%s construida." % name)
	return {"ok": true, "message": "%s construida." % name}


func get_state() -> Dictionary:
	return {"built_structures": built_structures.duplicate(true)}


func apply_state(state: Dictionary) -> void:
	built_structures = state.get("built_structures", []).duplicate(true)


func _get_resource_amount(key: String) -> int:
	match key:
		"money":
			return ResourceManager.money
		"water":
			return ResourceManager.water
		"food":
			return ResourceManager.food
		"medicine":
			return ResourceManager.medicine
		"wood":
			return ResourceManager.wood
		"seedlings":
			return ResourceManager.seedlings
		_:
			return 0


func _spend_resource(key: String, amount: int) -> void:
	match key:
		"money":
			ResourceManager.spend_money(amount)
		"water":
			ResourceManager.add_water(-amount)
		"food":
			ResourceManager.add_food(-amount)
		"medicine":
			ResourceManager.add_medicine(-amount)
		"wood":
			ResourceManager.add_wood(-amount)
		"seedlings":
			ResourceManager.add_seedlings(-amount)
