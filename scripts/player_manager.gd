extends Node

signal character_changed(character: Dictionary)

const CHARACTERS := {
	"joaquim": {
		"id": "joaquim",
		"name": "Joaquim",
		"sex": "Homem",
		"hair_label": "cabelo curto",
		"description": "Homem com cabelo curto, barba e roupa informal.",
		"shirt_color": Color(0.12, 0.35, 0.75),
		"pants_color": Color(0.09, 0.13, 0.18),
		"accent_color": Color(0.9, 0.68, 0.16),
		"hair_scale": Vector3(1.0, 0.68, 0.9),
		"has_capulana": false,
		"has_beard": true
	},
	"maica": {
		"id": "maica",
		"name": "Maica",
		"sex": "Mulher",
		"hair_label": "cabelo longo",
		"description": "Mulher com cabelo longo, capulana e roupa tradicional/informal.",
		"shirt_color": Color(0.86, 0.24, 0.42),
		"pants_color": Color(0.13, 0.23, 0.37),
		"accent_color": Color(0.12, 0.62, 0.56),
		"hair_scale": Vector3(1.12, 0.9, 1.08),
		"has_capulana": true,
		"has_beard": false
	},
	"gibrity": {
		"id": "gibrity",
		"name": "Gibrity",
		"sex": "Mulher",
		"hair_label": "cabelo longo",
		"description": "Mulher com cabelo longo, capulana colorida e roupa informal.",
		"shirt_color": Color(0.22, 0.36, 0.76),
		"pants_color": Color(0.16, 0.17, 0.22),
		"accent_color": Color(0.96, 0.58, 0.18),
		"hair_scale": Vector3(1.16, 0.86, 1.1),
		"has_capulana": true,
		"has_beard": false
	}
}

var selected_character_id := "maica"


func select_character(id: String) -> void:
	if not CHARACTERS.has(id):
		return
	selected_character_id = id
	character_changed.emit(get_selected_character())


func get_selected_character() -> Dictionary:
	return CHARACTERS[selected_character_id].duplicate(true)


func get_character_name() -> String:
	return get_selected_character().name


func get_all_characters() -> Array:
	var result: Array = []
	for id in CHARACTERS.keys():
		result.append(CHARACTERS[id].duplicate(true))
	return result
