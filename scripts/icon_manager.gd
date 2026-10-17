extends Node

const ICON_PATHS: Dictionary = {
	"play": "res://assets/icons/play.svg",
	"person": "res://assets/icons/person.svg",
	"mission": "res://assets/icons/mission.svg",
	"inventory": "res://assets/icons/inventory.svg",
	"options": "res://assets/icons/options.svg",
	"back": "res://assets/icons/back.svg",
	"money": "res://assets/icons/money.svg",
	"water": "res://assets/icons/water.svg",
	"food": "res://assets/icons/food.svg",
	"medicine": "res://assets/icons/medicine.svg",
	"wood": "res://assets/icons/wood.svg",
	"axe": "res://assets/icons/axe.svg",
	"hammer": "res://assets/icons/hammer.svg",
	"saw": "res://assets/icons/saw.svg",
	"first_aid": "res://assets/icons/first_aid.svg",
	"home": "res://assets/icons/home.svg"
}

var _cache: Dictionary = {}


func get_icon(id: String) -> Texture2D:
	if _cache.has(id):
		return _cache[id]
	var path: String = str(ICON_PATHS.get(id, ""))
	if path == "" or not ResourceLoader.exists(path):
		return null
	var texture: Texture2D = load(path)
	_cache[id] = texture
	return texture


func apply_to_button(button: Button, id: String) -> void:
	var texture: Texture2D = get_icon(id)
	if texture == null:
		return
	button.icon = texture
	button.expand_icon = true
