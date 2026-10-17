extends StaticBody3D

var protected: bool = false
var cut_down: bool = false
var wood_collected: bool = false


func _ready() -> void:
	add_to_group("interactable")


func interact(_player: Node) -> Dictionary:
	return {
		"type": "tree",
		"tree": self,
		"title": "Arvore comunitaria",
		"text": "Escolhe uma accao adequada. Cortar exige machado e concede madeira uma unica vez."
	}


func inspect() -> String:
	MissionManager.progress_action("inspect_tree", 1)
	if cut_down:
		return "Esta arvore ja foi cortada. O tronco ainda pode servir de referencia no terreno."
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
		return "Selecciona o machado para cortar arvores."
	if protected:
		return "Esta arvore esta protegida. Escolhe outra que possa ser usada para madeira."
	if cut_down:
		return "Esta arvore ja foi cortada."
	cut_down = true
	if not wood_collected:
		wood_collected = true
		ResourceManager.add_wood(3)
	MissionManager.progress_action("cut_tree", 1)
	_update_visual()
	return "Arvore cortada com machado. +3 madeira."


func _update_visual() -> void:
	var crown: Node = get_node_or_null("Crown")
	var trunk: Node = get_node_or_null("Trunk")
	if cut_down:
		if crown:
			crown.visible = false
		if trunk and trunk is Node3D:
			(trunk as Node3D).rotation_degrees.z = 82.0
			(trunk as Node3D).position = Vector3(0.65, 0.18, 0.0)
	else:
		if crown and crown is MeshInstance3D:
			var material := StandardMaterial3D.new()
			material.albedo_color = Color(0.16, 0.58, 0.24) if protected else Color(0.08, 0.42, 0.17)
			(crown as MeshInstance3D).material_override = material
