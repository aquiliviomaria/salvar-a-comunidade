extends StaticBody3D

@export var house_name := "Casa"
@export var residents := 5
@export var is_hospital := false


func _ready() -> void:
	add_to_group("interactable")
	if is_hospital:
		$Label3D.text = "🏥 %s" % house_name
		if has_node("RedCrossV"):
			$RedCrossV.visible = true
			$RedCrossH.visible = true
	else:
		$Label3D.text = "🏠 %s" % house_name
		if has_node("RedCrossV"):
			$RedCrossV.visible = false
			$RedCrossH.visible = false


func get_prompt(_player: Node) -> String:
	if is_hospital:
		return "E — Ver unidade sanitaria"
	return "E — Ver %s" % house_name


func interact(_player: Node) -> String:
	if is_hospital:
		if ResourceManager.medicine <= 0:
			ResourceManager.add_medicine(3)
			return "🏥 Unidade Sanitaria: medicamentos recebidos para transporte. Volte a interagir para entregar."
		return "💊 Fala com Antonio para entregar medicamentos pela missao da unidade sanitaria."
	return "🏠 %s com %d habitantes." % [house_name, residents]
