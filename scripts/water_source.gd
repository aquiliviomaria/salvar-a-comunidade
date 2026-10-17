extends Area3D

var uses_remaining := 8
var regen_timer := 0.0
const REGEN_TIME := 60.0


func _ready() -> void:
	add_to_group("interactable")
	_update_label()


func _process(delta: float) -> void:
	if uses_remaining < 8:
		regen_timer += delta
		if regen_timer >= REGEN_TIME:
			regen_timer = 0.0
			uses_remaining = min(uses_remaining + 2, 8)
			_update_label()


func interact(_player: Node) -> String:
	if uses_remaining <= 0:
		return "💧 Esta fonte esta temporariamente seca. Procura outro poco ou fonte de agua."
	uses_remaining -= 1
	ResourceManager.add_water(5)
	SoundManager.play_collect()
	_update_label()
	return "💧 Agua recolhida da fonte: +5 unidades."


func _update_label() -> void:
	var label := get_node_or_null("Label3D")
	if label:
		label.text = "💧 Fonte de agua" if uses_remaining > 0 else "💧 Fonte (seca)"
