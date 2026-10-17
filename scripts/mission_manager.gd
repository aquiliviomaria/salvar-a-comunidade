extends Node

signal mission_changed(title: String, description: String)
signal community_health_changed(value: int)
signal community_stats_changed(stats: Dictionary)
signal message_sent(text: String)
signal level_changed(level: int, xp: int, next_level_xp: int)
signal mission_completed(mission: Dictionary, rewards: Dictionary)

const STATE_AVAILABLE: String = "available"
const STATE_ACTIVE: String = "active"
const STATE_COMPLETED: String = "completed"
const STATE_FAILED: String = "failed"

var community_stats: Dictionary = {
	"wellbeing": 72,
	"water": 60,
	"food": 80,
	"health": 65,
	"environment": 90
}

var community_health: int = 72
var current_mission: String = ""
var player_level: int = 1
var xp: int = 0
var next_level_xp: int = 100
var mission_states: Dictionary = {}
var mission_progress: Dictionary = {}

var missions: Dictionary = {
	"find_water": {
		"title": "Encontrar agua segura",
		"category": "agua",
		"description": "Maria precisa de agua segura para as familias.",
		"npc": "Maria",
		"objectives": [
			{"id": "collect_water", "label": "Recolher 5 unidades de agua", "target": 5},
			{"id": "deliver_water", "label": "Entregar agua a Maria", "target": 1}
		],
		"deliver": {"water": 5},
		"reward": {"money": 90, "xp": 60, "water": 2},
		"stats": {"water": 14, "wellbeing": 7}
	},
	"protect_forest": {
		"title": "Proteger area ambiental",
		"category": "ambiente",
		"description": "Mateus quer reduzir cortes e marcar arvores importantes.",
		"npc": "Mateus",
		"objectives": [
			{"id": "inspect_tree", "label": "Inspeccionar uma arvore", "target": 1},
			{"id": "protect_tree", "label": "Proteger uma arvore da zona verde", "target": 1}
		],
		"reward": {"money": 80, "xp": 55, "seedlings": 2},
		"stats": {"environment": 14, "wellbeing": 5}
	},
	"hospital": {
		"title": "Transportar recursos para a unidade sanitaria",
		"category": "saude",
		"description": "Antonio precisa de medicamentos no posto de saude.",
		"npc": "Antonio",
		"objectives": [
			{"id": "collect_medicine", "label": "Ter 2 medicamentos", "target": 2},
			{"id": "deliver_medicine", "label": "Entregar medicamentos a Antonio", "target": 1}
		],
		"deliver": {"medicine": 2},
		"reward": {"money": 130, "xp": 80},
		"stats": {"health": 18, "wellbeing": 6}
	},
	"emergency": {
		"title": "Resolver situacao de emergencia",
		"category": "emergencia",
		"description": "Nando viu uma familia a precisar de primeiros socorros.",
		"npc": "Nando",
		"objectives": [
			{"id": "use_first_aid", "label": "Usar kit de primeiros socorros", "target": 1}
		],
		"required_tool": "first_aid",
		"reward": {"money": 110, "xp": 75},
		"stats": {"health": 12, "wellbeing": 9}
	},
	"safe_path": {
		"title": "Encontrar caminhos seguros",
		"category": "caminhos",
		"description": "Bento quer marcar um caminho seguro para escola e unidade sanitaria.",
		"npc": "Bento",
		"objectives": [
			{"id": "safe_path_marker", "label": "Confirmar um caminho seguro", "target": 1}
		],
		"reward": {"money": 75, "xp": 55},
		"stats": {"wellbeing": 8, "health": 5}
	},
	"distribute_food": {
		"title": "Distribuir recursos pelas familias",
		"category": "familias",
		"description": "Rosa tem alimentos no armazem e precisa de ajuda na distribuicao.",
		"npc": "Rosa",
		"objectives": [
			{"id": "collect_food", "label": "Ter 3 alimentos", "target": 3},
			{"id": "deliver_food", "label": "Entregar alimentos a Rosa", "target": 1}
		],
		"deliver": {"food": 3},
		"reward": {"money": 100, "xp": 65, "medicine": 1},
		"stats": {"food": 14, "wellbeing": 8}
	},
	"community_challenge": {
		"title": "Resolver desafios da comunidade",
		"category": "construcao",
		"description": "Sofia precisa de uma estrutura util para melhorar a vida diaria.",
		"npc": "Sofia",
		"objectives": [
			{"id": "cut_tree", "label": "Cortar uma arvore com machado", "target": 1},
			{"id": "build_structure", "label": "Construir uma casa, capoeira ou armazem", "target": 1}
		],
		"reward": {"money": 120, "xp": 90, "food": 2},
		"stats": {"wellbeing": 12, "food": 5}
	}
}


func _ready() -> void:
	reset()


func reset() -> void:
	community_stats = {
		"wellbeing": 72,
		"water": 60,
		"food": 80,
		"health": 65,
		"environment": 90
	}
	current_mission = ""
	player_level = 1
	xp = 0
	next_level_xp = 100
	mission_states.clear()
	mission_progress.clear()
	for mission_id: String in missions.keys():
		mission_states[mission_id] = STATE_AVAILABLE
		mission_progress[mission_id] = {}
		for objective: Dictionary in missions[mission_id].get("objectives", []):
			mission_progress[mission_id][str(objective.get("id", ""))] = 0
	_recalculate_health()
	_emit_all()


func accept_mission(id: String) -> Dictionary:
	if not missions.has(id):
		return {"ok": false, "message": "Missao desconhecida."}
	var state: String = str(mission_states.get(id, STATE_AVAILABLE))
	if state == STATE_COMPLETED:
		return {"ok": false, "message": "Esta missao ja foi concluida."}
	if current_mission != "" and current_mission != id:
		return {"ok": false, "message": "Termina ou abandona a missao activa antes de aceitar outra."}
	current_mission = id
	mission_states[id] = STATE_ACTIVE
	var mission: Dictionary = missions[id]
	mission_changed.emit(str(mission.title), get_mission_brief(id))
	message_sent.emit("Missao activa: %s" % str(mission.title))
	return {"ok": true, "message": "Missao aceite."}


func abandon_current_mission() -> void:
	if current_mission == "":
		return
	mission_states[current_mission] = STATE_AVAILABLE
	current_mission = ""
	mission_changed.emit("Sem missao", "Fale com os habitantes para receber tarefas.")
	message_sent.emit("Missao abandonada. O progresso foi mantido.")


func progress_action(action_id: String, amount: int = 1) -> void:
	if current_mission == "":
		return
	var mission: Dictionary = missions.get(current_mission, {})
	if mission.is_empty():
		return
	if not _mission_has_objective(current_mission, action_id):
		return
	var progress: Dictionary = mission_progress[current_mission]
	var current: int = int(progress.get(action_id, 0))
	var target: int = _objective_target(current_mission, action_id)
	progress[action_id] = clampi(current + max(amount, 0), 0, target)
	mission_changed.emit(str(mission.title), get_mission_brief(current_mission))
	if _can_auto_complete(current_mission):
		_complete_mission(current_mission)


func can_deliver_to_npc(npc_name: String, mission_id: String) -> bool:
	if current_mission != mission_id:
		return false
	if not missions.has(mission_id):
		return false
	var mission: Dictionary = missions[mission_id]
	return str(mission.get("npc", "")) == npc_name and mission.has("deliver")


func deliver_to_npc(npc_name: String, mission_id: String) -> Dictionary:
	if not can_deliver_to_npc(npc_name, mission_id):
		return {"ok": false, "message": "Esta entrega nao pertence a este cidadao."}
	var mission: Dictionary = missions[mission_id]
	var deliver: Dictionary = mission.get("deliver", {})
	var missing: Array = []
	for resource: String in deliver.keys():
		var required: int = int(deliver[resource])
		var current: int = _resource_amount(resource)
		if current < required:
			missing.append("%s %d/%d" % [resource, current, required])
	if missing.size() > 0:
		return {"ok": false, "message": "Ainda falta: %s" % ", ".join(missing)}
	for resource: String in deliver.keys():
		_spend_resource(resource, int(deliver[resource]))
	for objective: Dictionary in mission.get("objectives", []):
		var objective_id: String = str(objective.get("id", ""))
		if objective_id.begins_with("deliver_"):
			progress_action(objective_id, int(objective.get("target", 1)))
	return {"ok": true, "message": "Entrega concluida."}


func get_npc_context(npc_name: String, mission_id: String) -> Dictionary:
	var context: Dictionary = {
		"state": "none",
		"button": "Continuar",
		"mission": {},
		"brief": ""
	}
	if not missions.has(mission_id):
		return context
	var mission: Dictionary = missions[mission_id].duplicate(true)
	var state: String = str(mission_states.get(mission_id, STATE_AVAILABLE))
	context["mission"] = mission
	context["brief"] = get_mission_brief(mission_id)
	if state == STATE_COMPLETED:
		context["state"] = "completed"
		context["button"] = "Fechar"
	elif current_mission == mission_id:
		context["state"] = "active"
		context["button"] = "Entregar" if can_deliver_to_npc(npc_name, mission_id) else "Continuar"
	elif state == STATE_AVAILABLE:
		context["state"] = "available"
		context["button"] = "Aceitar"
	else:
		context["state"] = "none"
	return context


func complete_community_task(title: String, health_reward: int, xp_reward: int) -> void:
	_apply_stats({"wellbeing": health_reward})
	_add_xp(xp_reward)
	message_sent.emit("%s concluida. +%d XP" % [title, xp_reward])


func get_current_title() -> String:
	if current_mission == "" or not missions.has(current_mission):
		return "Sem missao"
	return str(missions[current_mission].title)


func get_mission_brief(id: String = "") -> String:
	var mission_id: String = id if id != "" else current_mission
	if mission_id == "" or not missions.has(mission_id):
		return "Fale com os habitantes para receber tarefas."
	var mission: Dictionary = missions[mission_id]
	var lines: Array = [str(mission.description), "", "Objectivos"]
	for objective: Dictionary in mission.get("objectives", []):
		var objective_id: String = str(objective.get("id", ""))
		var target: int = int(objective.get("target", 1))
		var value: int = int(mission_progress.get(mission_id, {}).get(objective_id, 0))
		var mark: String = "OK" if value >= target else "--"
		lines.append("%s %s (%d/%d)" % [mark, str(objective.get("label", "")), value, target])
	var reward: Dictionary = mission.get("reward", {})
	lines.append("")
	lines.append("Recompensa: %d MT, %d XP" % [int(reward.get("money", 0)), int(reward.get("xp", 0))])
	return "\n".join(lines)


func get_available_missions_summary() -> String:
	var lines: Array = []
	for mission_id: String in missions.keys():
		var state: String = str(mission_states.get(mission_id, STATE_AVAILABLE))
		var mission: Dictionary = missions[mission_id]
		lines.append("%s - %s [%s]" % [str(mission.title), str(mission.get("npc", "")), state])
	return "\n".join(lines)


func get_state() -> Dictionary:
	return {
		"community_stats": community_stats.duplicate(true),
		"current_mission": current_mission,
		"player_level": player_level,
		"xp": xp,
		"next_level_xp": next_level_xp,
		"mission_states": mission_states.duplicate(true),
		"mission_progress": mission_progress.duplicate(true)
	}


func apply_state(state: Dictionary) -> void:
	community_stats = state.get("community_stats", community_stats).duplicate(true)
	current_mission = str(state.get("current_mission", current_mission))
	player_level = int(state.get("player_level", player_level))
	xp = int(state.get("xp", xp))
	next_level_xp = int(state.get("next_level_xp", next_level_xp))
	mission_states = state.get("mission_states", mission_states).duplicate(true)
	mission_progress = state.get("mission_progress", mission_progress).duplicate(true)
	_recalculate_health()
	_emit_all()


func _can_auto_complete(mission_id: String) -> bool:
	if not _all_objectives_done(mission_id):
		return false
	var mission: Dictionary = missions[mission_id]
	return not mission.has("deliver")


func _complete_mission(mission_id: String) -> void:
	if str(mission_states.get(mission_id, "")) == STATE_COMPLETED:
		return
	var mission: Dictionary = missions[mission_id]
	var reward: Dictionary = mission.get("reward", {})
	ResourceManager.add_money(int(reward.get("money", 0)))
	ResourceManager.add_water(int(reward.get("water", 0)))
	ResourceManager.add_food(int(reward.get("food", 0)))
	ResourceManager.add_medicine(int(reward.get("medicine", 0)))
	ResourceManager.add_wood(int(reward.get("wood", 0)))
	ResourceManager.add_seedlings(int(reward.get("seedlings", 0)))
	_add_xp(int(reward.get("xp", 0)))
	_apply_stats(mission.get("stats", {}))
	mission_states[mission_id] = STATE_COMPLETED
	current_mission = ""
	mission_changed.emit("Sem missao", "Fale com outro habitante para continuar.")
	message_sent.emit("MISSÃO CONCLUÍDA: %s" % str(mission.title))
	var completed_mission: Dictionary = mission.duplicate(true)
	completed_mission["id"] = mission_id
	mission_completed.emit(completed_mission, reward.duplicate(true))


func _mission_has_objective(mission_id: String, action_id: String) -> bool:
	for objective: Dictionary in missions[mission_id].get("objectives", []):
		if str(objective.get("id", "")) == action_id:
			return true
	return false


func _objective_target(mission_id: String, action_id: String) -> int:
	for objective: Dictionary in missions[mission_id].get("objectives", []):
		if str(objective.get("id", "")) == action_id:
			return int(objective.get("target", 1))
	return 1


func _all_objectives_done(mission_id: String) -> bool:
	for objective: Dictionary in missions[mission_id].get("objectives", []):
		var objective_id: String = str(objective.get("id", ""))
		if int(mission_progress[mission_id].get(objective_id, 0)) < int(objective.get("target", 1)):
			return false
	return true


func _add_xp(amount: int) -> void:
	xp += max(amount, 0)
	while xp >= next_level_xp:
		xp -= next_level_xp
		player_level += 1
		next_level_xp += 50
		message_sent.emit("%s subiu para o nivel %d!" % [PlayerManager.get_character_name(), player_level])
	level_changed.emit(player_level, xp, next_level_xp)


func _apply_stats(delta: Dictionary) -> void:
	for key: String in delta.keys():
		if community_stats.has(key):
			community_stats[key] = clampi(int(community_stats[key]) + int(delta[key]), 0, 100)
	_recalculate_health()
	community_health_changed.emit(community_health)
	community_stats_changed.emit(community_stats.duplicate(true))


func _recalculate_health() -> void:
	var total: int = 0
	for value: Variant in community_stats.values():
		total += int(value)
	community_health = int(round(float(total) / float(community_stats.size())))


func _emit_all() -> void:
	community_health_changed.emit(community_health)
	community_stats_changed.emit(community_stats.duplicate(true))
	level_changed.emit(player_level, xp, next_level_xp)
	mission_changed.emit(get_current_title(), get_mission_brief())


func _resource_amount(resource: String) -> int:
	match resource:
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
		"money":
			return ResourceManager.money
		_:
			return 0


func _spend_resource(resource: String, amount: int) -> void:
	match resource:
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
		"money":
			ResourceManager.spend_money(amount)
