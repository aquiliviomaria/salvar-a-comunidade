extends Node3D

const PLAYER_SCENE := preload("res://scenes/player.tscn")
const NPC_SCENE := preload("res://scenes/npc.tscn")
const HOUSE_SCENE := preload("res://scenes/house.tscn")
const TREE_SCENE := preload("res://scenes/tree.tscn")
const WATER_SCENE := preload("res://scenes/water_source.tscn")
const MISSION_AREA_SCENE := preload("res://scenes/mission_area.tscn")
const WELL_SCENE := preload("res://scenes/well.tscn")

@onready var terrain: Node3D = $Terrain
@onready var houses: Node3D = $Houses
@onready var nature: Node3D = $Nature
@onready var npcs: Node3D = $NPCs
@onready var animals: Node3D = $Animals
@onready var interactables: Node3D = $Interactables
@onready var hud_layer: CanvasLayer = $HUD

var mission_title := "Sem missao"
var mission_description := "Fale com os habitantes para receber tarefas."
var player_level := 1
var player_xp := 0
var next_level_xp := 100
var shop_panel: PanelContainer
var player: Node3D
var top_left_label: Label
var top_right_label: Label
var message_label: Label
var prompt_label: Label
var tool_bar: HBoxContainer
var modal_layer: Control
var pause_panel: PanelContainer
var tool_menu: PanelContainer
var tool_menu_list: VBoxContainer
var modal_open := false
var build_position: Vector3 = Vector3.ZERO
var touch_controls: Control


func _ready() -> void:
	# Cada partida comeca fresca, respeitando a personagem escolhida no menu.
	# O progresso guardado continua acessivel com F9 (carregar).
	get_tree().paused = false
	ResourceManager.reset()
	MissionManager.reset()
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	_build_runtime_ui()
	ResourceManager.resources_changed.connect(_update_hud)
	MissionManager.mission_changed.connect(_on_mission_changed)
	MissionManager.community_health_changed.connect(_update_hud)
	MissionManager.community_stats_changed.connect(_update_hud)
	MissionManager.level_changed.connect(_on_level_changed)
	MissionManager.message_sent.connect(_show_message)
	MissionManager.mission_completed.connect(_show_mission_complete)
	ToolManager.tool_changed.connect(_on_tool_changed)
	ConstructionManager.message_sent.connect(_show_message)

	_build_world()
	_spawn_saved_structures()
	_spawn_player()
	_build_shop_panel()
	_update_hud()
	_show_message("%s | E interage | F ferramentas | B construcao | C loja." % PlayerManager.get_character_name())


func _build_world() -> void:
	_add_ground()
	_add_boundary_wall()
	_add_roads()
	_add_environment_details()
	_add_houses()
	_add_trees()
	_add_water()
	_add_npcs()
	_add_animals()
	_add_community_missions()


func _unhandled_input(event: InputEvent) -> void:
	# A tecla F abre/fecha as ferramentas. Quando a pausa esta aberta este
	# no esta pausado, por isso F nao afecta o mundo nesse momento.
	if event.is_action_pressed("toggle_tools") and not get_tree().paused:
		if not _is_typing_in_ui():
			_toggle_tools_menu()
			get_viewport().set_input_as_handled()
			return
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_F5:
			SaveManager.save_game()
			_show_message("💾 Jogo guardado.")
		if event.keycode == KEY_F9:
			if SaveManager.load_game():
				_show_message("📂 Jogo carregado.")
			else:
				_show_message("⚠️ Nenhum ficheiro de save encontrado.")


func _is_typing_in_ui() -> bool:
	var focused: Control = get_viewport().gui_get_focus_owner()
	return focused is LineEdit or focused is TextEdit


func _spawn_player() -> void:
	player = PLAYER_SCENE.instantiate()
	add_child(player)
	player.global_position = Vector3(0, 0.2, 8)
	player.interacted.connect(_handle_interaction_result)
	player.action_requested.connect(_on_player_action_requested)
	player.prompt_changed.connect(_on_player_prompt_changed)


func _add_ground() -> void:
	var mesh := MeshInstance3D.new()
	var plane := PlaneMesh.new()
	plane.size = Vector2(120, 120)
	mesh.mesh = plane
	mesh.material_override = _material(Color(0.28, 0.58, 0.31))
	terrain.add_child(mesh)

	var collision := StaticBody3D.new()
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(120, 0.2, 120)
	shape.shape = box
	collision.add_child(shape)
	collision.position.y = -0.1
	terrain.add_child(collision)


func _add_boundary_wall() -> void:
	var wall_material := Color(0.42, 0.36, 0.28)
	_add_solid_box(terrain, Vector3(0, 1.4, -60), Vector3(122, 2.8, 1.8), wall_material)
	_add_solid_box(terrain, Vector3(0, 1.4, 60), Vector3(122, 2.8, 1.8), wall_material)
	_add_solid_box(terrain, Vector3(-60, 1.4, 0), Vector3(1.8, 2.8, 122), wall_material)
	_add_solid_box(terrain, Vector3(60, 1.4, 0), Vector3(1.8, 2.8, 122), wall_material)
	for marker in [
		Vector3(-54, 3.25, -54),
		Vector3(54, 3.25, -54),
		Vector3(-54, 3.25, 54),
		Vector3(54, 3.25, 54)
	]:
		_add_solid_box(terrain, marker, Vector3(2.8, 1.1, 2.8), Color(0.48, 0.41, 0.32))


func _add_roads() -> void:
	_add_box(terrain, Vector3(0, 0.01, 0), Vector3(4.5, 0.04, 95.0), Color(0.28, 0.25, 0.22))
	_add_box(terrain, Vector3(0, 0.02, 1), Vector3(80.0, 0.04, 3.5), Color(0.31, 0.28, 0.24))
	_add_box(terrain, Vector3(-28, 0.025, -23), Vector3(34.0, 0.04, 3.0), Color(0.34, 0.29, 0.22))
	_add_box(terrain, Vector3(30, 0.025, 24), Vector3(28.0, 0.04, 3.0), Color(0.34, 0.29, 0.22))
	_add_box(terrain, Vector3(0, 0.035, 0), Vector3(12.0, 0.05, 12.0), Color(0.49, 0.43, 0.34))


func _add_environment_details() -> void:
	_add_box(terrain, Vector3(-18, 0.035, 24), Vector3(14, 0.06, 9), Color(0.34, 0.23, 0.13))
	for i in range(5):
		_add_box(terrain, Vector3(-23 + i * 2.5, 0.08, 24), Vector3(0.35, 0.1, 8.4), Color(0.18, 0.45, 0.18))
	_add_garden()
	_add_beach()

	for position in [
		Vector3(-5, 0.25, 5),
		Vector3(5, 0.25, 5),
		Vector3(-5, 0.25, -5),
		Vector3(5, 0.25, -5),
		Vector3(-16, 0.25, -19),
		Vector3(23, 0.25, 15)
	]:
		_add_lamp(position)

	for i in range(22):
		var x := -45 + (i % 11) * 8
		var z := -8 + int(i / 11) * 18
		_add_box(terrain, Vector3(x, 0.12, z), Vector3(0.55, 0.24, 0.55), Color(0.36, 0.36, 0.34))

	for i in range(18):
		var x := -38 + (i % 9) * 8.5
		var z := 42 + (i % 2) * 3.0
		_add_box(terrain, Vector3(x, 0.08, z), Vector3(0.35, 0.16, 0.35), Color(0.86, 0.74, 0.22))
	_add_market()
	_add_school()
	_add_pasture()


func _add_garden() -> void:
	_add_box(terrain, Vector3(-31, 0.04, 25), Vector3(13, 0.07, 10), Color(0.22, 0.42, 0.22))
	for row in range(4):
		for col in range(7):
			var flower_color := Color(0.9, 0.18 + row * 0.12, 0.25 + col * 0.04)
			_add_box(terrain, Vector3(-36 + col * 1.6, 0.22, 21.5 + row * 1.8), Vector3(0.28, 0.28, 0.28), flower_color)
	for i in range(6):
		_add_box(terrain, Vector3(-37 + i * 2.4, 0.32, 29.8), Vector3(0.25, 0.65, 0.25), Color(0.15, 0.5, 0.18))
		_add_box(terrain, Vector3(-37 + i * 2.4, 0.72, 29.8), Vector3(0.8, 0.18, 0.5), Color(0.08, 0.42, 0.12))


func _add_beach() -> void:
	_add_box(terrain, Vector3(43, 0.045, 47), Vector3(31, 0.08, 23), Color(0.82, 0.7, 0.46))
	_add_box(terrain, Vector3(49, 0.07, 53), Vector3(21, 0.08, 13), Color(0.12, 0.5, 0.86))
	for i in range(7):
		var palm := TREE_SCENE.instantiate()
		nature.add_child(palm)
		palm.global_position = Vector3(31 + i * 3.8, 0, 40 + (i % 2) * 3.0)
		palm.scale = Vector3(0.55, 1.2, 0.55)
	for i in range(5):
		_add_box(terrain, Vector3(36 + i * 4.2, 0.18, 34), Vector3(2.5, 0.18, 0.75), Color(0.56, 0.31, 0.16))


func _add_market() -> void:
	_add_box(terrain, Vector3(31, 0.05, 8), Vector3(13, 0.08, 8), Color(0.42, 0.32, 0.22))
	for i in range(4):
		var x := 26 + i * 3.0
		_add_solid_box(terrain, Vector3(x, 0.65, 8), Vector3(1.8, 1.2, 1.4), Color(0.68, 0.38, 0.16))
		_add_box(terrain, Vector3(x, 1.32, 8), Vector3(2.1, 0.16, 1.8), Color(0.86, 0.2 + i * 0.12, 0.18))
	var label := Label3D.new()
	label.text = "🏪 Mercado"
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label.position = Vector3(31, 2.1, 8)
	terrain.add_child(label)


func _add_market_interactable() -> void:
	var market_body := StaticBody3D.new()
	market_body.set_script(load("res://scripts/market.gd"))
	var col := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = Vector3(13, 3, 8)
	col.shape = shape
	market_body.add_child(col)
	interactables.add_child(market_body)
	market_body.global_position = Vector3(31, 1.5, 8)


func _add_school() -> void:
	_add_solid_box(terrain, Vector3(30, 1.0, -12), Vector3(6.5, 2.0, 4.0), Color(0.78, 0.7, 0.44))
	_add_box(terrain, Vector3(30, 2.15, -12), Vector3(7.1, 0.35, 4.45), Color(0.38, 0.13, 0.08))
	var label := Label3D.new()
	label.text = "🏫 Escola"
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label.position = Vector3(30, 2.9, -12)
	terrain.add_child(label)


func _add_pasture() -> void:
	_add_box(terrain, Vector3(-33, 0.04, -25), Vector3(25, 0.08, 19), Color(0.24, 0.48, 0.2))
	for i in range(12):
		_add_box(terrain, Vector3(-44 + i * 2.0, 0.28, -16), Vector3(0.14, 0.55, 0.14), Color(0.55, 0.36, 0.18))
		_add_box(terrain, Vector3(-44 + i * 2.0, 0.28, -34), Vector3(0.14, 0.55, 0.14), Color(0.55, 0.36, 0.18))
	var label := Label3D.new()
	label.text = "🐄 Pastos"
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label.position = Vector3(-33, 1.45, -25)
	terrain.add_child(label)


func _add_lamp(position: Vector3) -> void:
	_add_solid_box(terrain, position + Vector3(0, 0.75, 0), Vector3(0.18, 1.5, 0.18), Color(0.12, 0.1, 0.08))
	var lamp := OmniLight3D.new()
	lamp.position = position + Vector3(0, 1.65, 0)
	lamp.light_color = Color(1.0, 0.76, 0.42)
	lamp.light_energy = 0.65
	lamp.omni_range = 7.0
	terrain.add_child(lamp)
	_add_box(terrain, position + Vector3(0, 1.65, 0), Vector3(0.42, 0.28, 0.42), Color(0.95, 0.73, 0.28))


func _add_houses() -> void:
	var data := [
		["Casa Norte", Vector3(-8, 0, -6), 5, false],
		["Casa Sul", Vector3(8, 0, 6), 4, false],
		["Casa Familiar", Vector3(-10, 0, 7), 7, false],
		["Centro Comunitario", Vector3(9, 0, -6), 12, false],
		["Casa Nova", Vector3(-22, 0, -18), 6, false],
		["Armazem de Madeira", Vector3(24, 0, 18), 3, false],
		["Unidade Sanitaria", Vector3(18, 0, 0), 9, true]
	]
	for item in data:
		var house := HOUSE_SCENE.instantiate()
		house.house_name = item[0]
		house.residents = item[2]
		house.is_hospital = item[3]
		houses.add_child(house)
		house.global_position = item[1]
		if item[3]:
			house.scale = Vector3(1.8, 1.28, 1.45)


func _add_trees() -> void:
	for i in range(80):
		var tree := TREE_SCENE.instantiate()
		nature.add_child(tree)
		var band := int(i / 20)
		var x := -52 + (i % 20) * 2.8
		var z := -48 + band * 9.0 + (i % 4) * 1.1
		if band % 2 == 1:
			z = 32 + (i % 20) * 0.8
			x = -48 + (i % 20) * 4.8
		tree.global_position = Vector3(x, 0, z)
		tree.rotation.y = i * 0.35
		tree.scale = Vector3.ONE * (0.8 + (i % 3) * 0.12)

	for i in range(12):
		_add_box(nature, Vector3(-34 + i * 2.2, 0.22, 18 + (i % 3)), Vector3(1.4, 0.44, 0.42), Color(0.38, 0.22, 0.1))


func _add_water() -> void:
	# Fontes de agua (rios/lagos)
	var positions := [
		Vector3(-15, 0.12, 12),
		Vector3(-42, 0.12, -30),
		Vector3(38, 0.12, 32),
		Vector3(48, 0.12, -18)
	]
	for position in positions:
		var water := WATER_SCENE.instantiate()
		interactables.add_child(water)
		water.global_position = position

	# Pocos comunitarios
	var well_positions := [
		Vector3(-8, 0, 16),
		Vector3(14, 0, -18),
		Vector3(-36, 0, 14)
	]
	for pos in well_positions:
		var well := WELL_SCENE.instantiate()
		interactables.add_child(well)
		well.global_position = pos
	
	# Mercado interactivo
	_add_market_interactable()


func _add_npcs() -> void:
	for item in NPCManager.get_citizens():
		var npc := NPC_SCENE.instantiate()
		npc.npc_name = item.name
		npc.npc_type = item.type
		npc.age = item.age
		npc.profession = item.profession
		npc.home = item.home
		npc.state = item.state
		npc.dialogue = item.dialogue
		npc.mission_id = item.mission_id
		npcs.add_child(npc)
		npc.global_position = item.position


func _add_animals() -> void:
	var data := [
		# Galinhas perto das casas
		["chicken", Vector3(-9, 0.18, 10)],
		["chicken", Vector3(-12, 0.18, 8)],
		["chicken", Vector3(7, 0.18, 9)],
		["chicken", Vector3(-6, 0.18, 12)],
		["chicken", Vector3(9, 0.18, 14)],
		["chicken", Vector3(-14, 0.18, 5)],
		# Caes perto das casas
		["dog", Vector3(-7, 0.24, -8)],
		["dog", Vector3(11, 0.24, 8)],
		["dog", Vector3(-16, 0.24, -14)],
		# Bois nos pastos
		["ox", Vector3(-34, 0.45, -23)],
		["ox", Vector3(-27, 0.45, -28)],
		["ox", Vector3(-39, 0.45, -32)],
		["ox", Vector3(-22, 0.45, -30)],
		["ox", Vector3(-36, 0.45, -18)],
		# Cabritos nos pastos
		["goat", Vector3(-31, 0.35, -18)],
		["goat", Vector3(-24, 0.35, -25)],
		["goat", Vector3(-42, 0.35, -20)],
		["goat", Vector3(-28, 0.35, -32)],
		["goat", Vector3(-38, 0.35, -27)]
	]
	for item in data:
		var animal := AnimalManager.create_animal(item[0])
		animals.add_child(animal)
		animal.global_position = item[1]


func _add_community_missions() -> void:
	# [title, message, icon, position, color, health_reward, xp_reward, money_reward]
	var data := [
		["Socorrer familia", "Pessoas afectadas receberam apoio.", "🚑", Vector3(6, 0.08, -12), Color(0.88, 0.22, 0.2, 0.65), 10, 55, 80],
		["Reparar poco", "O poco comunitario voltou a funcionar.", "🛠", Vector3(-15, 0.08, 14), Color(0.12, 0.46, 0.88, 0.65), 12, 70, 100],
		["Organizar horta", "A horta comunitaria esta preparada.", "🌾", Vector3(-18, 0.08, 24), Color(0.22, 0.66, 0.22, 0.65), 8, 50, 60],
		["Plantar jardim", "O jardim ficou colorido e vivo.", "🌷", Vector3(-31, 0.08, 25), Color(0.9, 0.22, 0.55, 0.65), 9, 60, 70],
		["Limpar estrada", "A estrada principal ficou segura.", "🧹", Vector3(0, 0.08, 18), Color(0.86, 0.68, 0.25, 0.65), 7, 45, 50],
		["Apoiar escola", "Criancas receberam material escolar.", "📚", Vector3(28, 0.08, -10), Color(0.45, 0.28, 0.88, 0.65), 10, 65, 90],
		["Posto de saude", "O posto de saude recebeu organizacao.", "🏥", Vector3(22, 0.08, 4), Color(0.95, 0.32, 0.32, 0.65), 10, 60, 100],
		["Cuidar da praia", "A praia esta limpa para a comunidade.", "🏖", Vector3(43, 0.08, 43), Color(0.18, 0.55, 0.9, 0.65), 8, 55, 60]
	]
	for item in data:
		var area := MISSION_AREA_SCENE.instantiate()
		area.title = item[0]
		area.message = item[1]
		area.icon = item[2]
		area.health_reward = item[5]
		area.xp_reward = item[6]
		area.money_reward = item[7]
		interactables.add_child(area)
		area.global_position = item[3]
		area.get_node("MeshInstance3D").material_override = _material(item[4])


func _add_box(parent: Node, position: Vector3, size: Vector3, color: Color) -> MeshInstance3D:
	var mesh := MeshInstance3D.new()
	var box := BoxMesh.new()
	box.size = size
	mesh.mesh = box
	mesh.position = position
	mesh.material_override = _material(color)
	parent.add_child(mesh)
	return mesh


func _add_solid_box(parent: Node, position: Vector3, size: Vector3, color: Color) -> StaticBody3D:
	var body := StaticBody3D.new()
	body.position = position
	var mesh := MeshInstance3D.new()
	var box_mesh := BoxMesh.new()
	box_mesh.size = size
	mesh.mesh = box_mesh
	mesh.material_override = _material(color)
	body.add_child(mesh)
	var collision := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = size
	collision.shape = shape
	body.add_child(collision)
	parent.add_child(body)
	return body


func _on_player_action_requested(action: String, position: Vector3) -> void:
	match action:
		"build_house":
			_build_player_house(position)
		"open_build_menu":
			build_position = position
			_show_build_menu(position)
		"plant_tree":
			_plant_player_tree(position)
		"toggle_shop":
			if shop_panel:
				shop_panel.visible = not shop_panel.visible
				if shop_panel.visible and tool_menu:
					tool_menu.visible = false
				_refresh_pointer_state()


func _build_player_house(position: Vector3) -> void:
	if not ResourceManager.build_house():
		_show_message("Recursos insuficientes: construir casa custa 3 madeiras e 1 agua.")
		return
	var house := HOUSE_SCENE.instantiate()
	house.house_name = "Casa Construida"
	house.residents = 4
	houses.add_child(house)
	house.global_position = position.snapped(Vector3(1, 1, 1))
	MissionManager.progress_action("build_structure", 1)
	_show_message("🏠 Casa construida para uma familia. A comunidade ficou mais forte.")


func _plant_player_tree(position: Vector3) -> void:
	if not ResourceManager.plant_tree():
		_show_message("Recursos insuficientes: plantar arvore custa 1 muda e 1 agua.")
		return
	var tree := TREE_SCENE.instantiate()
	nature.add_child(tree)
	tree.global_position = position.snapped(Vector3(1, 1, 1))
	tree.scale = Vector3.ONE * 0.65
	MissionManager.progress_action("protect_tree", 1)
	_show_message("🌱 Arvore plantada. A area verde da comunidade aumentou.")


func _material(color: Color) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	return material


func _build_shop_panel() -> void:
	shop_panel = PanelContainer.new()
	shop_panel.visible = false
	shop_panel.custom_minimum_size = Vector2(420, 0)
	# Posiciona no canto direito do ecra
	shop_panel.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	shop_panel.offset_left = -460.0
	shop_panel.offset_top = 80.0
	shop_panel.offset_right = -20.0
	shop_panel.offset_bottom = 580.0

	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.04, 0.07, 0.06, 0.95)
	style.border_color = Color(0.74, 0.62, 0.34, 0.7)
	style.set_border_width_all(1)
	style.set_corner_radius_all(10)
	style.set_content_margin_all(16)
	shop_panel.add_theme_stylebox_override("panel", style)
	$HUD.add_child(shop_panel)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 16)
	margin.add_theme_constant_override("margin_top", 14)
	margin.add_theme_constant_override("margin_right", 16)
	margin.add_theme_constant_override("margin_bottom", 14)
	shop_panel.add_child(margin)

	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 10)
	margin.add_child(box)

	var title := Label.new()
	title.text = "🏪 LOJA DA COMUNIDADE"
	title.add_theme_font_size_override("font_size", 20)
	title.add_theme_color_override("font_color", Color(1.0, 0.9, 0.58))
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(title)

	var sep := HSeparator.new()
	box.add_child(sep)

	var items := [
		["💧 Agua (+5 unidades)", 50, "water"],
		["🍚 Alimento (+3 unidades)", 40, "food"],
		["💊 Medicamento (+2 unidades)", 80, "medicine"],
		["🪵 Madeira (+4 unidades)", 60, "wood"],
		["🌱 Muda de arvore (+3 unidades)", 45, "seedlings"]
	]
	for item in items:
		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 8)
		box.add_child(row)

		var lbl := Label.new()
		lbl.text = item[0]
		lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		lbl.add_theme_font_size_override("font_size", 15)
		lbl.add_theme_color_override("font_color", Color(0.88, 0.92, 0.82))
		row.add_child(lbl)

		var price_lbl := Label.new()
		price_lbl.text = "%d MT" % item[1]
		price_lbl.add_theme_font_size_override("font_size", 15)
		price_lbl.add_theme_color_override("font_color", Color(1.0, 0.82, 0.36))
		row.add_child(price_lbl)

		var btn := Button.new()
		btn.text = "COMPRAR"
		btn.custom_minimum_size = Vector2(90, 34)
		btn.add_theme_font_size_override("font_size", 13)
		var btn_style := StyleBoxFlat.new()
		btn_style.bg_color = Color(0.12, 0.23, 0.18, 0.95)
		btn_style.border_color = Color(0.56, 0.68, 0.42, 0.7)
		btn_style.set_border_width_all(1)
		btn_style.set_corner_radius_all(6)
		btn.add_theme_stylebox_override("normal", btn_style)
		var btn_hover := btn_style.duplicate() as StyleBoxFlat
		btn_hover.bg_color = Color(0.18, 0.32, 0.24, 0.95)
		btn.add_theme_stylebox_override("hover", btn_hover)
		btn.pressed.connect(_shop_buy.bind(item[2], int(item[1])))
		row.add_child(btn)

	var close_sep := HSeparator.new()
	box.add_child(close_sep)

	var close_btn := Button.new()
	close_btn.text = "FECHAR (C)"
	close_btn.add_theme_font_size_override("font_size", 15)
	var close_style := StyleBoxFlat.new()
	close_style.bg_color = Color(0.22, 0.08, 0.08, 0.95)
	close_style.border_color = Color(0.88, 0.28, 0.28, 0.7)
	close_style.set_border_width_all(1)
	close_style.set_corner_radius_all(6)
	close_btn.add_theme_stylebox_override("normal", close_style)
	close_btn.pressed.connect(func():
		shop_panel.visible = false
		_refresh_pointer_state()
	)
	box.add_child(close_btn)


func _shop_buy(resource: String, cost: int) -> void:
	if not ResourceManager.spend_money(cost):
		_show_message("💰 Dinheiro insuficiente. Precisas de %d MT." % cost)
		return
	match resource:
		"water":
			ResourceManager.add_water(5)
			_show_message("💧 Compraste 5 unidades de agua por %d MT." % cost)
		"food":
			ResourceManager.add_food(3)
			_show_message("🍚 Compraste 3 unidades de alimento por %d MT." % cost)
		"medicine":
			ResourceManager.add_medicine(2)
			_show_message("💊 Compraste 2 medicamentos por %d MT." % cost)
		"wood":
			ResourceManager.add_wood(4)
			_show_message("🪵 Compraste 4 madeiras por %d MT." % cost)
		"seedlings":
			ResourceManager.add_seedlings(3)
			_show_message("🌱 Compraste 3 mudas de arvore por %d MT." % cost)


func _on_mission_changed(title: String, description: String) -> void:
	mission_title = title
	mission_description = description
	_update_hud()


func _on_level_changed(level: int, xp: int, required_xp: int) -> void:
	player_level = level
	player_xp = xp
	next_level_xp = required_xp
	_update_hud()


func _show_message(text: String) -> void:
	if message_label:
		message_label.text = text


func _update_hud(_a = null, _b = null, _c = null, _d = null) -> void:
	if top_left_label:
		top_left_label.text = "%s   Nivel %d (%d/%d XP)\nMT %d   Agua %d   Alimento %d   Medic. %d   Madeira %d" % [
			PlayerManager.get_character_name(),
			player_level,
			player_xp,
			next_level_xp,
			ResourceManager.money,
			ResourceManager.water,
			ResourceManager.food,
			ResourceManager.medicine,
			ResourceManager.wood
		]
	if top_right_label:
		top_right_label.text = "%s\n%s" % [mission_title, _first_lines(mission_description, 4)]
	_update_tool_bar()


func _build_runtime_ui() -> void:
	# O HUD continua a receber eventos mesmo com a arvore pausada.
	hud_layer.process_mode = Node.PROCESS_MODE_ALWAYS
	var old_top: Node = hud_layer.get_node_or_null("TopPanel")
	if old_top:
		old_top.queue_free()
	var old_message: Node = hud_layer.get_node_or_null("MessagePanel")
	if old_message:
		old_message.queue_free()

	top_left_label = _make_floating_label(Vector2(18, 14), 16, HORIZONTAL_ALIGNMENT_LEFT)
	hud_layer.add_child(top_left_label)
	top_right_label = _make_floating_label(Vector2(760, 14), 15, HORIZONTAL_ALIGNMENT_RIGHT)
	top_right_label.size = Vector2(480, 170)
	hud_layer.add_child(top_right_label)
	prompt_label = _make_floating_label(Vector2(380, 632), 18, HORIZONTAL_ALIGNMENT_CENTER)
	prompt_label.size = Vector2(520, 32)
	prompt_label.text = ""
	hud_layer.add_child(prompt_label)
	message_label = _make_floating_label(Vector2(20, 670), 16, HORIZONTAL_ALIGNMENT_LEFT)
	message_label.size = Vector2(900, 36)
	hud_layer.add_child(message_label)
	tool_bar = HBoxContainer.new()
	tool_bar.position = Vector2(390, 674)
	tool_bar.add_theme_constant_override("separation", 12)
	hud_layer.add_child(tool_bar)
	modal_layer = Control.new()
	modal_layer.set_anchors_preset(Control.PRESET_FULL_RECT)
	modal_layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hud_layer.add_child(modal_layer)
	_build_pause_panel()
	_build_tools_menu()
	_build_touch_controls()
	_build_pause_controller()
	_update_tool_bar()


func _make_floating_label(position: Vector2, font_size: int, alignment: HorizontalAlignment) -> Label:
	var label := Label.new()
	label.position = position
	label.size = Vector2(520, 96)
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", Color(0.97, 0.94, 0.84))
	label.add_theme_color_override("font_shadow_color", Color(0.02, 0.03, 0.025, 0.9))
	label.add_theme_constant_override("shadow_offset_x", 2)
	label.add_theme_constant_override("shadow_offset_y", 2)
	label.horizontal_alignment = alignment
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	return label


func _update_tool_bar(_tool_id: String = "") -> void:
	if tool_bar == null:
		return
	for child: Node in tool_bar.get_children():
		child.queue_free()
	for tool: Dictionary in ToolManager.get_tools():
		var item := HBoxContainer.new()
		item.add_theme_constant_override("separation", 4)
		var selected: bool = bool(tool.get("selected", false))
		var icon := TextureRect.new()
		icon.custom_minimum_size = Vector2(22, 22)
		icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		icon.texture = IconManager.get_icon(str(tool.get("icon", "")))
		item.add_child(icon)
		var label := Label.new()
		label.text = "%s %s" % [str(tool.get("shortcut", "")), str(tool.get("name", ""))]
		label.add_theme_font_size_override("font_size", 14)
		label.add_theme_color_override("font_color", Color(1.0, 0.82, 0.38) if selected else Color(0.9, 0.92, 0.84))
		label.add_theme_color_override("font_shadow_color", Color(0.02, 0.03, 0.02, 0.95))
		label.add_theme_constant_override("shadow_offset_x", 2)
		label.add_theme_constant_override("shadow_offset_y", 2)
		item.add_child(label)
		tool_bar.add_child(item)
	var hint := Label.new()
	hint.text = "   F ferramentas"
	hint.add_theme_font_size_override("font_size", 13)
	hint.add_theme_color_override("font_color", Color(0.72, 0.78, 0.70))
	hint.add_theme_color_override("font_shadow_color", Color(0.02, 0.03, 0.02, 0.95))
	hint.add_theme_constant_override("shadow_offset_x", 2)
	hint.add_theme_constant_override("shadow_offset_y", 2)
	tool_bar.add_child(hint)


func _on_tool_changed(_tool_id: String) -> void:
	_update_tool_bar()
	SoundManager.play_ui()
	_show_message("Ferramenta: %s" % str(ToolManager.get_selected_tool().get("name", "")))


func _first_lines(text: String, max_lines: int) -> String:
	var lines: PackedStringArray = text.split("\n")
	var result: Array = []
	var count: int = min(max_lines, lines.size())
	for index: int in range(count):
		result.append(lines[index])
	return "\n".join(result)


func _handle_interaction_result(data: Variant) -> void:
	if typeof(data) == TYPE_STRING:
		_show_message(str(data))
		return
	if typeof(data) != TYPE_DICTIONARY:
		return
	var payload: Dictionary = data
	match str(payload.get("type", "")):
		"npc":
			_show_npc_popup(payload)
		"tree":
			_show_tree_popup(payload)
		_:
			_show_message(str(payload))


func _clear_modal() -> void:
	for child: Node in modal_layer.get_children():
		if child != pause_panel:
			child.queue_free()
	modal_open = false
	_refresh_pointer_state()


func _has_modal() -> bool:
	return modal_open


func _refresh_pointer_state() -> void:
	# Decide o dono do rato: pausa > modal > menu de ferramentas > loja > jogo.
	if get_tree().paused:
		modal_layer.mouse_filter = Control.MOUSE_FILTER_STOP
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		return
	if modal_open:
		modal_layer.mouse_filter = Control.MOUSE_FILTER_STOP
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		return
	if tool_menu and tool_menu.visible:
		modal_layer.mouse_filter = Control.MOUSE_FILTER_STOP
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		return
	if shop_panel and shop_panel.visible:
		modal_layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		return
	modal_layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _show_modal(title: String, body: String, buttons: Array) -> void:
	_clear_modal()
	modal_open = true
	_refresh_pointer_state()
	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(560, 0)
	panel.set_anchors_preset(Control.PRESET_CENTER)
	panel.offset_left = -280.0
	panel.offset_top = -210.0
	panel.offset_right = 280.0
	panel.offset_bottom = 210.0
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.035, 0.055, 0.05, 0.96)
	style.border_color = Color(0.72, 0.58, 0.28, 0.9)
	style.set_border_width_all(1)
	style.set_corner_radius_all(8)
	style.set_content_margin_all(18)
	panel.add_theme_stylebox_override("panel", style)
	modal_layer.add_child(panel)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 12)
	panel.add_child(box)
	var title_label := Label.new()
	title_label.text = title
	title_label.add_theme_font_size_override("font_size", 26)
	title_label.add_theme_color_override("font_color", Color(1.0, 0.84, 0.42))
	box.add_child(title_label)
	var body_label := Label.new()
	body_label.text = body
	body_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	body_label.add_theme_font_size_override("font_size", 17)
	body_label.add_theme_color_override("font_color", Color(0.91, 0.93, 0.86))
	body_label.size_flags_vertical = Control.SIZE_EXPAND_FILL
	box.add_child(body_label)
	var row := HBoxContainer.new()
	row.alignment = BoxContainer.ALIGNMENT_END
	row.add_theme_constant_override("separation", 10)
	box.add_child(row)
	for button_data: Dictionary in buttons:
		var button := Button.new()
		button.text = str(button_data.get("text", "Fechar"))
		button.custom_minimum_size = Vector2(110, 40)
		var callback: Callable = button_data.get("callback", Callable(self, "_clear_modal"))
		button.pressed.connect(callback)
		row.add_child(button)


func _show_npc_popup(payload: Dictionary) -> void:
	var npc_name: String = str(payload.get("name", "Cidadao"))
	var mission_id: String = str(payload.get("mission_id", ""))
	var context: Dictionary = MissionManager.get_npc_context(npc_name, mission_id)
	var mission: Dictionary = context.get("mission", {})
	var body: String = "%s\n\nProfissao: %s\nEstado: %s\nCasa: %s" % [
		str(payload.get("dialogue", "")),
		str(payload.get("profession", "")),
		str(payload.get("state", "")),
		str(payload.get("home", ""))
	]
	if not mission.is_empty():
		body += "\n\n%s\n%s" % [str(mission.get("title", "")), str(context.get("brief", ""))]
	var state: String = str(context.get("state", ""))
	var buttons: Array = []
	if state == "active" and not mission.is_empty():
		# Se a missao exige uma ferramenta e o jogador a tem seleccionada,
		# permite executar a accao especifica (ex.: primeiros socorros).
		var required_tool: String = str(mission.get("required_tool", ""))
		var tool_objective: String = str(mission.get("tool_objective", ""))
		if required_tool != "" and tool_objective != "" and ToolManager.selected_tool_id == required_tool:
			if not MissionManager.is_objective_done(mission_id, tool_objective):
				buttons.append({"text": "Prestar primeiros socorros", "callback": Callable(self, "_use_tool_objective").bind(mission_id, tool_objective)})
	match state:
		"available":
			buttons.append({"text": "Aceitar", "callback": Callable(self, "_accept_npc_mission").bind(mission_id)})
		"active":
			if str(context.get("button", "")) == "Entregar":
				buttons.append({"text": "Entregar", "callback": Callable(self, "_deliver_npc_mission").bind(npc_name, mission_id)})
			else:
				buttons.append({"text": "Continuar", "callback": Callable(self, "_clear_modal")})
		_:
			buttons.append({"text": "Fechar", "callback": Callable(self, "_clear_modal")})
	buttons.append({"text": "Fechar", "callback": Callable(self, "_clear_modal")})
	_show_modal(npc_name, body, buttons)


func _use_tool_objective(mission_id: String, objective_id: String) -> void:
	# Fecha o dialogo antes de progredir, para que o ecra de conclusao possa aparecer.
	_clear_modal()
	MissionManager.progress_action(objective_id, 1)
	SoundManager.play_collect()
	_show_message("Accao concluida com %s." % str(ToolManager.get_selected_tool().get("name", "a ferramenta")))


func _accept_npc_mission(mission_id: String) -> void:
	var result: Dictionary = MissionManager.accept_mission(mission_id)
	SoundManager.play_ui()
	_show_message(str(result.get("message", "")))
	_clear_modal()


func _deliver_npc_mission(npc_name: String, mission_id: String) -> void:
	var result: Dictionary = MissionManager.deliver_to_npc(npc_name, mission_id)
	if bool(result.get("ok", false)):
		SoundManager.play_success()
	else:
		SoundManager.play_error()
	_show_message(str(result.get("message", "")))
	if bool(result.get("ok", false)):
		_clear_modal()


func _show_tree_popup(payload: Dictionary) -> void:
	var tree: Node = payload.get("tree", null)
	if tree == null:
		return
	var buttons: Array = [
		{"text": "Inspeccionar", "callback": Callable(self, "_tree_action").bind(tree, "inspect")},
		{"text": "Proteger", "callback": Callable(self, "_tree_action").bind(tree, "protect")},
		{"text": "Cortar", "callback": Callable(self, "_tree_action").bind(tree, "cut")},
		{"text": "Fechar", "callback": Callable(self, "_clear_modal")}
	]
	_show_modal(str(payload.get("title", "Arvore")), str(payload.get("text", "")), buttons)


func _tree_action(tree: Node, action: String) -> void:
	var text: String = ""
	match action:
		"inspect":
			text = str(tree.call("inspect"))
		"protect":
			text = str(tree.call("protect_tree"))
		"cut":
			text = str(tree.call("cut_tree"))
	_show_message(text)
	_clear_modal()


func _show_build_menu(position: Vector3) -> void:
	if ToolManager.selected_tool_id != "hammer":
		_show_message("Selecciona o martelo para construir.")
		return
	build_position = position
	var body: String = "Escolhe uma estrutura para construir perto do jogador.\n\n"
	var buttons: Array = []
	for structure: Dictionary in ConstructionManager.get_structures():
		var cost: Dictionary = structure.get("cost", {})
		body += "%s: %s | %s\n" % [str(structure.get("name", "")), _format_cost(cost), str(structure.get("effect", ""))]
		buttons.append({"text": str(structure.get("name", "")), "callback": Callable(self, "_build_structure").bind(str(structure.get("id", "")))})
	buttons.append({"text": "Cancelar", "callback": Callable(self, "_clear_modal")})
	_show_modal("Construir", body, buttons)


func _build_structure(structure_id: String) -> void:
	var snapped: Vector3 = build_position.snapped(Vector3(1, 1, 1))
	if not _is_build_position_valid(snapped):
		SoundManager.play_error()
		_clear_modal()
		_show_message("Nao podes construir aqui. Procura um espaco livre na comunidade.")
		return
	var result: Dictionary = ConstructionManager.build(structure_id, snapped)
	if bool(result.get("ok", false)):
		_spawn_structure(structure_id, snapped)
		MissionManager.progress_action("build_structure", 1)
		SoundManager.play_build()
	else:
		SoundManager.play_error()
	_clear_modal()
	_show_message(str(result.get("message", "")))


func _is_build_position_valid(position: Vector3) -> bool:
	if absf(position.x) > 55.0 or absf(position.z) > 55.0:
		return false
	for house: Node in houses.get_children():
		if house is Node3D and (house as Node3D).global_position.distance_to(position) < 4.0:
			return false
	for item: Dictionary in ConstructionManager.built_structures:
		if Vector3(item.get("position", Vector3.ZERO)).distance_to(position) < 3.0:
			return false
	return true


func _spawn_structure(structure_id: String, position: Vector3) -> void:
	var data: Dictionary = ConstructionManager.STRUCTURES.get(structure_id, {})
	var size: Vector3 = data.get("size", Vector3(3, 2, 3))
	var color: Color = data.get("color", Color(0.5, 0.4, 0.3))
	var body: StaticBody3D = _add_solid_box(houses, position + Vector3(0, size.y * 0.5, 0), size, color)
	var label := Label3D.new()
	label.text = str(data.get("name", "Estrutura"))
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label.position = Vector3(0, size.y * 0.65, 0)
	body.add_child(label)


func _spawn_saved_structures() -> void:
	for item: Dictionary in ConstructionManager.built_structures:
		var structure_id: String = str(item.get("id", ""))
		var position: Vector3 = item.get("position", Vector3.ZERO)
		if ConstructionManager.STRUCTURES.has(structure_id):
			_spawn_structure(structure_id, position)


func _format_cost(cost: Dictionary) -> String:
	var parts: Array = []
	for key: String in cost.keys():
		parts.append("%s %d" % [key, int(cost[key])])
	return ", ".join(parts)


func _show_mission_complete(mission: Dictionary, rewards: Dictionary) -> void:
	SoundManager.play_success()
	if player and player.has_method("celebrate"):
		player.call("celebrate")
	var body: String = "Parabens, %s!\n\n%s\n\nRecompensas: %d MT, %d XP\nImpacto positivo aplicado na comunidade." % [
		PlayerManager.get_character_name(),
		MissionManager.get_mission_brief(str(mission.get("id", ""))),
		int(rewards.get("money", 0)),
		int(rewards.get("xp", 0))
	]
	_show_modal("MISSAO CONCLUIDA!", body, [{"text": "Continuar", "callback": Callable(self, "_clear_modal")}])


func _build_pause_panel() -> void:
	pause_panel = PanelContainer.new()
	pause_panel.visible = false
	pause_panel.custom_minimum_size = Vector2(380, 0)
	pause_panel.set_anchors_preset(Control.PRESET_CENTER)
	pause_panel.offset_left = -190.0
	pause_panel.offset_top = -200.0
	pause_panel.offset_right = 190.0
	pause_panel.offset_bottom = 200.0
	modal_layer.add_child(pause_panel)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 10)
	pause_panel.add_child(box)
	var title := Label.new()
	title.text = "Pausa"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 26)
	box.add_child(title)
	var continue_btn := Button.new()
	continue_btn.text = "Continuar"
	continue_btn.pressed.connect(_toggle_pause)
	box.add_child(continue_btn)
	var restart_btn := Button.new()
	restart_btn.text = "Reiniciar"
	restart_btn.pressed.connect(_restart_game)
	box.add_child(restart_btn)
	var options_btn := Button.new()
	options_btn.text = "Opcoes"
	options_btn.pressed.connect(func(): _show_message("Opcoes: usa F5 para guardar e F9 para carregar."))
	box.add_child(options_btn)
	var menu_btn := Button.new()
	menu_btn.text = "Menu Principal"
	menu_btn.pressed.connect(_return_to_menu)
	box.add_child(menu_btn)
	var quit_btn := Button.new()
	quit_btn.text = "Sair"
	quit_btn.pressed.connect(_quit_game)
	box.add_child(quit_btn)


func _quit_game() -> void:
	SaveManager.save_game()
	get_tree().paused = false
	get_tree().quit()


func handle_cancel() -> void:
	# ESC contextual: fecha o que estiver aberto antes de pausar.
	if tool_menu and tool_menu.visible:
		_close_tools_menu()
		return
	if shop_panel and shop_panel.visible:
		shop_panel.visible = false
		_refresh_pointer_state()
		return
	if modal_open:
		_clear_modal()
		return
	_toggle_pause()


func _toggle_pause() -> void:
	var paused: bool = not get_tree().paused
	if paused and tool_menu and tool_menu.visible:
		tool_menu.visible = false
	get_tree().paused = paused
	pause_panel.visible = paused
	_refresh_pointer_state()


func _restart_game() -> void:
	get_tree().paused = false
	pause_panel.visible = false
	modal_open = false
	ResourceManager.reset()
	MissionManager.reset()
	get_tree().reload_current_scene()


func _return_to_menu() -> void:
	SaveManager.save_game()
	get_tree().paused = false
	pause_panel.visible = false
	modal_open = false
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	get_tree().change_scene_to_file("res://scenes/title_screen.tscn")


func _build_pause_controller() -> void:
	var controller := Node.new()
	controller.name = "PauseInput"
	controller.set_script(load("res://scripts/pause_input.gd"))
	hud_layer.add_child(controller)


func _on_player_prompt_changed(text: String) -> void:
	if prompt_label:
		prompt_label.text = text


func _build_tools_menu() -> void:
	tool_menu = PanelContainer.new()
	tool_menu.name = "ToolsMenu"
	tool_menu.visible = false
	tool_menu.custom_minimum_size = Vector2(440, 0)
	tool_menu.set_anchors_preset(Control.PRESET_CENTER)
	tool_menu.offset_left = -220.0
	tool_menu.offset_top = -250.0
	tool_menu.offset_right = 220.0
	tool_menu.offset_bottom = 250.0
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.035, 0.06, 0.05, 0.97)
	style.border_color = Color(0.72, 0.62, 0.30, 0.9)
	style.set_border_width_all(1)
	style.set_corner_radius_all(10)
	style.set_content_margin_all(18)
	tool_menu.add_theme_stylebox_override("panel", style)
	hud_layer.add_child(tool_menu)

	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 10)
	tool_menu.add_child(box)

	var title := Label.new()
	title.text = "FERRAMENTAS  (F)"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 22)
	title.add_theme_color_override("font_color", Color(1.0, 0.86, 0.45))
	box.add_child(title)

	var hint := Label.new()
	hint.text = "Escolhe a ferramenta certa para cada accao no mundo."
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	hint.add_theme_font_size_override("font_size", 14)
	hint.add_theme_color_override("font_color", Color(0.82, 0.86, 0.78))
	box.add_child(hint)
	box.add_child(HSeparator.new())

	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	box.add_child(scroll)
	tool_menu_list = VBoxContainer.new()
	tool_menu_list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	tool_menu_list.add_theme_constant_override("separation", 8)
	scroll.add_child(tool_menu_list)

	var close_btn := Button.new()
	close_btn.text = "Fechar (F)"
	close_btn.pressed.connect(_close_tools_menu)
	box.add_child(close_btn)


func _populate_tools_menu() -> void:
	for child: Node in tool_menu_list.get_children():
		child.queue_free()
	for tool: Dictionary in ToolManager.get_tools():
		var tool_id: String = str(tool.get("id", ""))
		var selected: bool = bool(tool.get("selected", false))
		var icon := IconManager.get_icon(str(tool.get("icon", "")))
		var entry := Button.new()
		entry.text = "%s%s  (tecla %s)" % ["▶ " if selected else "   ", str(tool.get("name", "")), str(tool.get("shortcut", ""))]
		entry.custom_minimum_size = Vector2(0, 42)
		entry.icon = icon
		entry.expand_icon = true
		entry.icon_alignment = HORIZONTAL_ALIGNMENT_LEFT
		entry.add_theme_font_size_override("font_size", 16)
		entry.add_theme_color_override("font_color", Color(1.0, 0.86, 0.45) if selected else Color(0.93, 0.95, 0.88))
		entry.pressed.connect(_select_tool_from_menu.bind(tool_id))
		tool_menu_list.add_child(entry)
		var desc := Label.new()
		desc.text = str(tool.get("description", ""))
		desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		desc.add_theme_font_size_override("font_size", 13)
		desc.add_theme_color_override("font_color", Color(0.76, 0.82, 0.74))
		tool_menu_list.add_child(desc)


func _toggle_tools_menu() -> void:
	if tool_menu == null:
		return
	if tool_menu.visible:
		_close_tools_menu()
	else:
		_open_tools_menu()


func _open_tools_menu() -> void:
	if get_tree().paused or modal_open:
		return
	if shop_panel:
		shop_panel.visible = false
	_populate_tools_menu()
	tool_menu.visible = true
	_refresh_pointer_state()


func _close_tools_menu() -> void:
	if tool_menu:
		tool_menu.visible = false
	_refresh_pointer_state()


func _select_tool_from_menu(tool_id: String) -> void:
	if ToolManager.select_tool(tool_id):
		_close_tools_menu()


func _build_touch_controls() -> void:
	touch_controls = Control.new()
	touch_controls.set_anchors_preset(Control.PRESET_FULL_RECT)
	touch_controls.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hud_layer.add_child(touch_controls)
	var interact_button := _make_touch_button("E", Vector2(1150, 570), "interact")
	var tool_button := _make_touch_button("Ferramentas", Vector2(1020, 625), "tool")
	var build_button := _make_touch_button("Construir", Vector2(1140, 625), "build")
	touch_controls.add_child(interact_button)
	touch_controls.add_child(tool_button)
	touch_controls.add_child(build_button)


func _make_touch_button(text: String, position: Vector2, action: String) -> Button:
	var button := Button.new()
	button.text = text
	button.position = position
	button.custom_minimum_size = Vector2(92, 46)
	button.mouse_filter = Control.MOUSE_FILTER_STOP
	button.add_theme_font_size_override("font_size", 15)
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.03, 0.06, 0.05, 0.42)
	style.border_color = Color(0.95, 0.82, 0.44, 0.55)
	style.set_border_width_all(1)
	style.set_corner_radius_all(8)
	button.add_theme_stylebox_override("normal", style)
	var hover := style.duplicate() as StyleBoxFlat
	hover.bg_color = Color(0.16, 0.28, 0.22, 0.72)
	button.add_theme_stylebox_override("hover", hover)
	button.pressed.connect(_on_touch_button.bind(action))
	return button


func _on_touch_button(action: String) -> void:
	if player == null:
		return
	if get_tree().paused or modal_open or (tool_menu and tool_menu.visible):
		return
	match action:
		"interact":
			player.call("_interact")
		"tool":
			_toggle_tools_menu()
		"build":
			_show_build_menu(player.global_position + (-player.global_transform.basis.z.normalized() * 4.0))
