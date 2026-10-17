extends StaticBody3D

var uses_remaining := 5


func _ready() -> void:
	add_to_group("interactable")
	_update_label()


func interact(_player: Node) -> String:
	if uses_remaining <= 0:
		return "💧 O poco esta vazio. Volta mais tarde ou procura outra fonte de agua."
	uses_remaining -= 1
	ResourceManager.add_water(3)
	SoundManager.play_collect()
	_update_label()
	return "💧 Agua recolhida do poco: +3 unidades. Usos restantes: %d" % uses_remaining


func _update_label() -> void:
	var label := get_node_or_null("Label3D")
	if label:
		if uses_remaining > 0:
			label.text = "💧 Poco\n(%d usos)" % uses_remaining
		else:
			label.text = "💧 Poco\n(vazio)"
