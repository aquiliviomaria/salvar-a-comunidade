extends Area3D

# Fonte de agua natural (rio/lago). Tem usos limitados e recupera com o tempo.
# Nao desaparece do mundo: apenas fica temporariamente indisponivel.

var uses_remaining := 8
var regen_timer := 0.0
const MAX_USES := 8
const REGEN_TIME := 60.0


func _ready() -> void:
	add_to_group("interactable")
	_update_visual()


func _process(delta: float) -> void:
	if uses_remaining < MAX_USES:
		regen_timer += delta
		if regen_timer >= REGEN_TIME:
			regen_timer = 0.0
			uses_remaining = mini(uses_remaining + 2, MAX_USES)
			_update_visual()


func get_prompt(_player: Node) -> String:
	if uses_remaining <= 0:
		return ""
	return "E — Recolher agua"


func interact(_player: Node) -> String:
	if uses_remaining <= 0:
		return "💧 Esta fonte esta temporariamente seca. Procura outro ponto de agua."
	uses_remaining -= 1
	ResourceManager.add_water(5)
	SoundManager.play_collect()
	_update_visual()
	return "💧 Agua recolhida da fonte: +5 unidades."


func _update_visual() -> void:
	var mesh := get_node_or_null("MeshInstance3D") as MeshInstance3D
	if mesh:
		mesh.visible = uses_remaining > 0
	var label := get_node_or_null("Label3D") as Label3D
	if label:
		label.text = "💧 Fonte de agua" if uses_remaining > 0 else "💧 Fonte (em recuperacao)"
