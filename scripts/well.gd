extends StaticBody3D

# Poco comunitario. Estrutura permanente: nao desaparece, mas fica sem agua
# temporariamente e recupera ao longo do tempo.

var uses_remaining := 5
var regen_timer := 0.0
const MAX_USES := 5
const REGEN_TIME := 45.0


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
		return "💧 O poco esta vazio. Volta mais tarde ou procura outra fonte de agua."
	uses_remaining -= 1
	ResourceManager.add_water(3)
	SoundManager.play_collect()
	_update_visual()
	return "💧 Agua recolhida do poco: +3 unidades. Usos restantes: %d" % uses_remaining


func _update_visual() -> void:
	var water := get_node_or_null("Water") as MeshInstance3D
	if water:
		water.visible = uses_remaining > 0
	var label := get_node_or_null("Label3D") as Label3D
	if label:
		if uses_remaining > 0:
			label.text = "💧 Poco\n(%d usos)" % uses_remaining
		else:
			label.text = "💧 Poco\n(em recuperacao)"
