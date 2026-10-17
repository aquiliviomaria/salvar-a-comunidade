extends Node

const SAVE_PATH := "user://salvar_a_comunidade.save"


func save_game() -> void:
	var data := {
			"version": 2,
			"character_id": PlayerManager.selected_character_id,
			"resources": ResourceManager.get_state(),
			"missions": MissionManager.get_state(),
			"tools": ToolManager.get_state(),
			"constructions": ConstructionManager.get_state()
	}
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		file.store_var(data)


func load_game() -> bool:
	if not FileAccess.file_exists(SAVE_PATH):
		return false
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if not file:
		return false
	var data = file.get_var()
	if not data is Dictionary:
		return false
	# Ignora saves de versoes anteriores incompativeis
	if int(data.get("version", 1)) < 2:
		return false
	if data.has("character_id"):
		PlayerManager.select_character(str(data.character_id))
	if data.has("resources"):
		ResourceManager.apply_state(data.resources)
	if data.has("missions"):
		MissionManager.apply_state(data.missions)
	if data.has("tools"):
		ToolManager.apply_state(data.tools)
	if data.has("constructions"):
		ConstructionManager.apply_state(data.constructions)
	return true


func delete_save() -> void:
	if FileAccess.file_exists(SAVE_PATH):
		DirAccess.remove_absolute(SAVE_PATH)
