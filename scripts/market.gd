extends StaticBody3D

func _ready() -> void:
	add_to_group("interactable")


func interact(_player: Node) -> String:
	return "🏪 Mercado: aqui vendem-se e trocam-se recursos.\n💰 Dinheiro: %d MT   💧 %d   🍚 %d   💊 %d\nPressiona C para abrir a loja e comprar recursos." % [
		ResourceManager.money,
		ResourceManager.water,
		ResourceManager.food,
		ResourceManager.medicine
	]
