extends Node

signal tool_changed(tool_id: String)
signal tools_changed()

const TOOLS: Dictionary = {
	"axe": {
		"name": "Machado",
		"icon": "axe",
		"type": "cut",
		"shortcut": "1",
		"description": "Corta arvores marcadas e recolhe madeira."
	},
	"hammer": {
		"name": "Martelo",
		"icon": "hammer",
		"type": "build",
		"shortcut": "2",
		"description": "Constroi e repara estruturas comunitarias."
	},
	"saw": {
		"name": "Serrote",
		"icon": "saw",
		"type": "woodwork",
		"shortcut": "3",
		"description": "Prepara madeira para construcao."
	},
	"collector": {
		"name": "Recolha",
		"icon": "inventory",
		"type": "collect",
		"shortcut": "4",
		"description": "Recolhe agua, alimento e materiais."
	},
	"first_aid": {
		"name": "Primeiros socorros",
		"icon": "first_aid",
		"type": "health",
		"shortcut": "5",
		"description": "Ajuda em emergencias e na unidade sanitaria."
	}
}

var selected_tool_id: String = "collector"
var owned_tools: Dictionary = {
	"axe": true,
	"hammer": true,
	"saw": true,
	"collector": true,
	"first_aid": true
}


func select_tool(tool_id: String) -> bool:
	if not TOOLS.has(tool_id) or not owned_tools.get(tool_id, false):
		return false
	selected_tool_id = tool_id
	tool_changed.emit(tool_id)
	return true


func get_selected_tool() -> Dictionary:
	return get_tool(selected_tool_id)


func get_tool(tool_id: String) -> Dictionary:
	return TOOLS.get(tool_id, {}).duplicate(true)


func has_tool(tool_id: String) -> bool:
	return bool(owned_tools.get(tool_id, false))


func get_tools() -> Array:
	var result: Array = []
	for tool_id: String in TOOLS.keys():
		var tool: Dictionary = TOOLS[tool_id].duplicate(true)
		tool["id"] = tool_id
		tool["owned"] = has_tool(tool_id)
		tool["selected"] = tool_id == selected_tool_id
		result.append(tool)
	return result


func get_state() -> Dictionary:
	return {
		"selected_tool_id": selected_tool_id,
		"owned_tools": owned_tools.duplicate(true)
	}


func apply_state(state: Dictionary) -> void:
	owned_tools = state.get("owned_tools", owned_tools).duplicate(true)
	select_tool(str(state.get("selected_tool_id", selected_tool_id)))
	tools_changed.emit()
