extends StaticBody3D

# Arvore interactiva da comunidade.
# Guarda o estado do corte/proteccao e regenera ao fim de algum tempo,
# para que a floresta nao desapareca para sempre.

@export var regrow_seconds := 120.0

var protected: bool = false
var cut_down: bool = false
var wood_collected: bool = false
var planks_collected: bool = false

var _trunk_position := Vector3.ZERO
var _trunk_rotation := Vector3.ZERO
var _regrow_timer: Timer


func _ready() -> void:
	add_to_group("interactable")
	_remember_trunk()
	_regrow_timer = Timer.new()
	_regrow_timer.one_shot = true
	_regrow_timer.wait_time = maxf(regrow_seconds, 5.0)
	_regrow_timer.timeout.connect(_regrow)
	add_child(_regrow_timer)


func _remember_trunk() -> void:
	var trunk := get_node_or_null("Trunk") as Node3D
	if trunk:
		_trunk_position = trunk.position
		_trunk_rotation = trunk.rotation_degrees


func get_prompt(_player: Node) -> String:
	if cut_down:
		if not planks_collected and ToolManager.selected_tool_id == "saw":
			return "E — Serrar madeira"
		return "E — Inspeccionar"
	if protected:
		return "E — Inspeccionar arvore protegida"
	if ToolManager.selected_tool_id == "axe" and ToolManager.has_tool("axe"):
		return "E — Cortar arvore"
	return "E — Inspeccionar / Proteger"


func interact(_player: Node) -> Variant:
	# Com o machado seleccionado, o corte e directo (uma arvore por accao).
	if cut_down:
		if not planks_collected and ToolManager.selected_tool_id == "saw" and ToolManager.has_tool("saw"):
			return _saw_wood()
		return _inspect_payload()
	if not protected and ToolManager.selected_tool_id == "axe" and ToolManager.has_tool("axe"):
		return cut_tree()
	return _inspect_payload()


func _inspect_payload() -> Dictionary:
	return {
		"type": "tree",
		"tree": self,
		"title": "Arvore comunitaria",
		"text": "Escolhe uma accao adequada. Cortar exige machado e concede madeira uma unica vez."
	}


func inspect() -> String:
	MissionManager.progress_action("inspect_tree", 1)
	if cut_down:
		return "Esta arvore ja foi cortada. O tronco ainda pode ser aproveitado com o serrote."
	if protected:
		return "Esta arvore esta marcada como protegida."
	return "Arvore saudavel. Pode ser protegida ou cortada se a missao exigir madeira."


func protect_tree() -> String:
	if cut_down:
		return "Nao e possivel proteger uma arvore ja cortada."
	if protected:
		return "Esta arvore ja esta protegida."
	protected = true
	MissionManager.progress_action("protect_tree", 1)
	_update_visual()
	return "Arvore protegida. A zona verde ficou mais segura."


func cut_tree() -> String:
	if not ToolManager.has_tool("axe") or ToolManager.selected_tool_id != "axe":
		return "Precisas do machado para cortar arvores. Usa F para escolher a ferramenta."
	if protected:
		return "Esta arvore esta protegida. Escolhe outra que possa ser usada para madeira."
	if cut_down:
		return "Esta arvore ja foi cortada."
	cut_down = true
	if not wood_collected:
		wood_collected = true
		ResourceManager.add_wood(3)
	MissionManager.progress_action("cut_tree", 1)
	SoundManager.play_cut()
	_update_visual()
	_animate_cut()
	if _regrow_timer and regrow_seconds > 0.0:
		_regrow_timer.start()
	return "Arvore cortada com machado. +3 madeira."


func _saw_wood() -> String:
	if not cut_down:
		return "So podes serrar um tronco ja cortado."
	if planks_collected:
		return "Este tronco ja foi aproveitado."
	planks_collected = true
	ResourceManager.add_wood(2)
	SoundManager.play_cut()
	return "Tronco serrado com o serrote. +2 madeira."


func _update_visual() -> void:
	var crown: Node = get_node_or_null("Crown")
	var trunk: Node = get_node_or_null("Trunk")
	if cut_down:
		# A copa desaparece; o tronco cai com animacao em _animate_cut().
		if crown:
			crown.visible = false
	else:
		if trunk and trunk is Node3D:
			(trunk as Node3D).rotation_degrees = _trunk_rotation
			(trunk as Node3D).position = _trunk_position
		if crown and crown is MeshInstance3D:
			crown.visible = true
			var material := StandardMaterial3D.new()
			material.albedo_color = Color(0.16, 0.58, 0.24) if protected else Color(0.08, 0.42, 0.17)
			(crown as MeshInstance3D).material_override = material


func _animate_cut() -> void:
	var trunk := get_node_or_null("Trunk") as Node3D
	if trunk == null:
		return
	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(trunk, "rotation_degrees:z", 82.0, 0.3).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
	tween.tween_property(trunk, "position", Vector3(0.65, 0.18, 0.0), 0.3).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)


func _regrow() -> void:
	cut_down = false
	wood_collected = false
	planks_collected = false
	protected = false
	_update_visual()
