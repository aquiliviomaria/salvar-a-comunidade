extends Node

# Teste de fumo temporario. Instancia a cena principal e valida as
# funcionalidades alteradas. Nao faz parte do jogo.

var failures: int = 0


func _check(condition: bool, label: String) -> void:
	if condition:
		print("PASS: ", label)
	else:
		failures += 1
		print("FAIL: ", label)


func _ready() -> void:
	await get_tree().process_frame
	_check(PlayerManager.selected_character_id == "maica", "personagem predefinida e Maica")

	var world_scene: PackedScene = load("res://scenes/main.tscn")
	var world: Node = world_scene.instantiate()
	add_child(world)
	await get_tree().process_frame
	await get_tree().process_frame
	await get_tree().physics_frame

	# --- Pausa ---
	_check(world.hud_layer.process_mode == Node.PROCESS_MODE_ALWAYS, "HUD processa durante a pausa")
	world._toggle_pause()
	_check(get_tree().paused, "pausa activa a arvore")
	_check(world.pause_panel.visible, "painel de pausa visivel")
	var continue_button: Button = _find_button(world.pause_panel, "Continuar")
	_check(continue_button != null, "botao Continuar existe")
	if continue_button:
		continue_button.emit_signal("pressed")
	_check(not get_tree().paused, "botao Continuar retoma o jogo")
	world._toggle_pause()
	_check(get_tree().paused, "pausa volta a activar")
	world._toggle_pause()
	_check(not get_tree().paused, "continuar retoma o jogo")
	world.handle_cancel()
	_check(get_tree().paused, "ESC abre a pausa")
	world.handle_cancel()
	_check(not get_tree().paused, "ESC fecha a pausa")

	# --- Ferramentas (F) ---
	world._toggle_tools_menu()
	_check(world.tool_menu.visible, "menu de ferramentas abre")
	_check(Input.mouse_mode == Input.MOUSE_MODE_VISIBLE, "rato visivel no menu de ferramentas")
	world._toggle_tools_menu()
	_check(not world.tool_menu.visible, "menu de ferramentas fecha")

	# --- Corte de arvore com machado ---
	ToolManager.select_tool("axe")
	_check(ToolManager.selected_tool_id == "axe", "machado seleccionado")
	var tree: Node = null
	for child in world.nature.get_children():
		if child.has_method("cut_tree") and not child.cut_down:
			tree = child
			break
	_check(tree != null, "existe uma arvore cortavel")
	if tree != null:
		var wood_before: int = ResourceManager.wood
		var result: String = str(tree.cut_tree())
		_check(result.contains("+3 madeira"), "corte devolve +3 madeira")
		_check(ResourceManager.wood == wood_before + 3, "madeira aumentou")
		_check(tree.cut_down, "arvore marcada como cortada")
		_check(not tree.get_node("Crown").visible, "copa escondida apos corte")
		var second: String = str(tree.cut_tree())
		_check(second.contains("ja foi cortada"), "nao ha madeira infinita")
		tree._regrow()
		_check(not tree.cut_down and tree.get_node("Crown").visible, "arvore regenera")

	# --- Recolha de agua (fonte) ---
	var water_source: Node = null
	for child in world.interactables.get_children():
		if child.has_method("get_prompt") and child.get_script() and str(child.get_script().resource_path).ends_with("water_source.gd"):
			water_source = child
			break
	_check(water_source != null, "existe uma fonte de agua")
	if water_source != null:
		var water_before: int = ResourceManager.water
		var uses_before: int = water_source.uses_remaining
		water_source.interact(world.player)
		_check(ResourceManager.water == water_before + 5, "fonte da +5 agua")
		_check(water_source.uses_remaining == uses_before - 1, "fonte consome um uso")

	# --- Recolha de agua (poco) ---
	var well: Node = null
	for child in world.interactables.get_children():
		if child.has_method("get_prompt") and child.get_script() and str(child.get_script().resource_path).ends_with("well.gd"):
			well = child
			break
	_check(well != null, "existe um poco")
	if well != null:
		var water_before2: int = ResourceManager.water
		well.interact(world.player)
		_check(ResourceManager.water == water_before2 + 3, "poco da +3 agua")

	# --- Construcao ---
	ToolManager.select_tool("hammer")
	var build_ok: bool = world._is_build_position_valid(Vector3(-8, 0, -6))
	_check(not build_ok, "bloqueia construcao sobre objectos existentes")
	var free_position := Vector3(0, 0, 40)
	_check(world._is_build_position_valid(free_position), "aceita posicao livre")
	var before_structures: int = ConstructionManager.built_structures.size()
	world.build_position = free_position
	world._build_structure("fence")
	_check(ConstructionManager.built_structures.size() == before_structures + 1, "construcao registada")

	# --- Missoes ---
	MissionManager.reset()
	var accept: Dictionary = MissionManager.accept_mission("find_water")
	_check(bool(accept.get("ok", false)), "missao de agua aceite")
	var prog_before: int = int(MissionManager.mission_progress["find_water"].get("collect_water", 0))
	ResourceManager.add_water(5)
	var prog_after: int = int(MissionManager.mission_progress["find_water"].get("collect_water", 0))
	_check(prog_after == mini(prog_before + 5, 5), "recolha de agua progride a missao")

	# --- Missao de emergencia com primeiros socorros ---
	_check(MissionManager.missions.has("feed_animals"), "missao dos animais existe")
	MissionManager.reset()
	MissionManager.accept_mission("emergency")
	ToolManager.select_tool("first_aid")
	world._use_tool_objective("emergency", "use_first_aid")
	_check(str(MissionManager.mission_states.get("emergency", "")) == "completed", "primeiros socorros concluem a missao de emergencia")

	# --- Entrega conclui a missao ---
	MissionManager.reset()
	MissionManager.accept_mission("find_water")
	ResourceManager.add_water(5)
	MissionManager.deliver_to_npc("Maria", "find_water")
	_check(str(MissionManager.mission_states.get("find_water", "")) == "completed", "entrega conclui a missao de agua")

	# --- Area da missao "caminho seguro" ---
	var safe_area: Node = null
	for child in world.interactables.get_children():
		if child.get("objective_id") == "safe_path_marker":
			safe_area = child
			break
	_check(safe_area != null, "existe area de caminho seguro")
	if safe_area != null:
		MissionManager.reset()
		var blocked: String = str(safe_area.interact(world.player))
		_check(blocked.contains("Aceita primeiro"), "caminho seguro exige missao activa")
		_check(not safe_area.completed, "area nao completa sem missao")
		MissionManager.accept_mission("safe_path")
		safe_area.interact(world.player)
		_check(str(MissionManager.mission_states.get("safe_path", "")) == "completed", "caminho seguro conclui a missao")

	# --- Textos em portugues ---
	var summary: String = MissionManager.get_available_missions_summary()
	_check(not summary.contains("available") and not summary.contains("completed"), "estados de missao em portugues")

	# --- Menu inicial limpa a pausa ---
	get_tree().paused = true
	var title: Node = (load("res://scenes/title_screen.tscn") as PackedScene).instantiate()
	add_child(title)
	await get_tree().process_frame
	_check(not get_tree().paused, "menu inicial desactiva a pausa")
	title.queue_free()

	print("\nRESULTADO: ", "OK" if failures == 0 else "FALHAS=%d" % failures)
	get_tree().quit(0 if failures == 0 else 1)


func _find_button(root: Node, text: String) -> Button:
	for node in root.get_children():
		if node is Button and (node as Button).text == text:
			return node as Button
		var found: Button = _find_button(node, text)
		if found:
			return found
	return null
