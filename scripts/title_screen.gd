extends Control

const MAIN_SCENE_PATH: String = "res://scenes/main.tscn"

@onready var start_button: Button = %StartButton
@onready var character_button: Button = %CharacterButton
@onready var missions_button: Button = %MissionsButton
@onready var inventory_button: Button = %InventoryButton
@onready var how_to_button: Button = %HowToButton
@onready var options_button: Button = %OptionsButton
@onready var quit_button: Button = %QuitButton
@onready var status_label: Label = %StatusLabel
@onready var content_title: Label = %ContentTitle
@onready var content_text: Label = %ContentText
@onready var character_list: VBoxContainer = %CharacterList
@onready var character_area: VBoxContainer = %CharacterArea
@onready var selected_character_label: Label = %SelectedCharacterLabel
@onready var avatar_frame: PanelContainer = %AvatarFrame
@onready var avatar_image: TextureRect = %AvatarImage


func _ready() -> void:
	# Garante que o menu nunca herda um estado de pausa do jogo.
	get_tree().paused = false
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	start_button.pressed.connect(_on_start_pressed)
	character_button.pressed.connect(_show_characters)
	missions_button.pressed.connect(_show_missions)
	inventory_button.pressed.connect(_show_inventory)
	how_to_button.pressed.connect(_show_how_to)
	options_button.pressed.connect(_show_options)
	quit_button.pressed.connect(_on_quit_pressed)
	$RootMargin/Layout/MainPanel/MainContent/CharacterArea/BackButton.pressed.connect(_show_home)
	PlayerManager.character_changed.connect(_on_character_changed)

	_build_character_buttons()
	_build_preview_world()
	_style_menu_buttons()
	_apply_icons()
	_on_character_changed(PlayerManager.get_selected_character())
	_show_home()
	start_button.grab_focus()


func _on_start_pressed() -> void:
	SoundManager.play_ui()
	ResourceManager.reset()
	MissionManager.reset()
	var error: Error = get_tree().change_scene_to_file(MAIN_SCENE_PATH)
	if error != OK:
		status_label.text = "Nao foi possivel abrir a cena principal."


func _on_quit_pressed() -> void:
	get_tree().quit()


func _show_home() -> void:
	character_area.visible = false
	content_title.text = "Bem-vindo"
	content_text.text = "A personagem escolhida vai liderar as accoes na comunidade.\n\nEntra na aldeia, fala com os habitantes, aceita missoes e melhora a agua, a saude, a alimentacao, o ambiente e a habitacao.\n\nUsa o menu Personagens para trocar de personagem."


func _show_characters() -> void:
	SoundManager.play_ui()
	character_area.visible = true
	content_title.text = "Personagens"
	content_text.text = "Selecciona quem vai liderar as accoes comunitarias. A escolha muda o visual do jogador no mundo 3D e mantem-se quando iniciares a partida."
	_refresh_character_buttons()


func _show_missions() -> void:
	SoundManager.play_ui()
	character_area.visible = false
	content_title.text = "Missoes comunitarias"
	content_text.text = MissionManager.get_available_missions_summary()


func _show_inventory() -> void:
	SoundManager.play_ui()
	character_area.visible = false
	content_title.text = "Inventario"
	content_text.text = "Recursos\nMT: %d\nAgua: %d\nAlimentos: %d\nMedicamentos: %d\nMadeira: %d\nMudas: %d\n\nFerramentas\n%s" % [
		ResourceManager.money,
		ResourceManager.water,
		ResourceManager.food,
		ResourceManager.medicine,
		ResourceManager.wood,
		ResourceManager.seedlings,
		_tools_summary()
	]


func _show_how_to() -> void:
	SoundManager.play_ui()
	character_area.visible = false
	content_title.text = "Como jogar"
	content_text.text = "WASD: mover\nRato: controlar a camara\nE: interagir (falar, recolher agua, cortar)\nF: abrir/fechar o menu de ferramentas\n1-5: escolher rapidamente uma ferramenta\nB: construir com o martelo\nT: plantar uma arvore\nC: abrir a loja do mercado\nEsc: pausa / fechar menus"


func _show_options() -> void:
	SoundManager.play_ui()
	character_area.visible = false
	content_title.text = "Opcoes"
	content_text.text = "Progresso: F5 guarda e F9 carrega durante o jogo.\nPausa: Esc no jogo.\nInterface: HUD minimalista com informacoes soltas no cenario.\n\nAs opcoes visuais e audio podem ser expandidas quando houver assets finais."


func _build_character_buttons() -> void:
	for child: Node in character_list.get_children():
		child.queue_free()

	var characters: Array = PlayerManager.get_all_characters()
	for character_data: Dictionary in characters:
		var button := Button.new()
		var character_id: String = str(character_data.get("id", ""))
		button.text = str(character_data.get("name", "Personagem"))
		button.custom_minimum_size = Vector2(0.0, 40.0)
		button.focus_mode = Control.FOCUS_ALL
		IconManager.apply_to_button(button, "person")
		button.pressed.connect(_select_character.bind(character_id))
		character_list.add_child(button)


func _refresh_character_buttons() -> void:
	for button: Button in character_list.get_children():
		var is_selected: bool = button.text == PlayerManager.get_character_name()
		button.add_theme_color_override("font_color", Color(1.0, 0.86, 0.45) if is_selected else Color(0.9, 0.93, 0.86))


func _tools_summary() -> String:
	var lines: Array = []
	for tool: Dictionary in ToolManager.get_tools():
		lines.append("%s - tecla %s" % [str(tool.get("name", "")), str(tool.get("shortcut", ""))])
	return "\n".join(lines)


func _apply_icons() -> void:
	IconManager.apply_to_button(start_button, "play")
	IconManager.apply_to_button(character_button, "person")
	IconManager.apply_to_button(missions_button, "mission")
	IconManager.apply_to_button(inventory_button, "inventory")
	IconManager.apply_to_button(how_to_button, "mission")
	IconManager.apply_to_button(options_button, "options")
	IconManager.apply_to_button(quit_button, "back")


func _style_menu_buttons() -> void:
	var buttons: Array[Button] = [
		start_button,
		character_button,
		missions_button,
		inventory_button,
		how_to_button,
		options_button,
		quit_button
	]
	for button: Button in buttons:
		button.icon_alignment = HORIZONTAL_ALIGNMENT_LEFT
		button.add_theme_constant_override("h_separation", 10)
		button.add_theme_font_size_override("font_size", 16)
		var normal := StyleBoxFlat.new()
		normal.bg_color = Color(0.09, 0.19, 0.15, 0.92)
		normal.border_color = Color(0.46, 0.62, 0.43, 0.55)
		normal.set_border_width_all(1)
		normal.set_corner_radius_all(6)
		normal.set_content_margin_all(10)
		var hover := normal.duplicate() as StyleBoxFlat
		hover.bg_color = Color(0.16, 0.32, 0.24, 0.98)
		hover.border_color = Color(0.95, 0.78, 0.34, 0.9)
		var pressed := normal.duplicate() as StyleBoxFlat
		pressed.bg_color = Color(0.78, 0.52, 0.18, 1.0)
		var disabled := normal.duplicate() as StyleBoxFlat
		disabled.bg_color = Color(0.07, 0.09, 0.08, 0.72)
		button.add_theme_stylebox_override("normal", normal)
		button.add_theme_stylebox_override("hover", hover)
		button.add_theme_stylebox_override("pressed", pressed)
		button.add_theme_stylebox_override("disabled", disabled)


func _build_preview_world() -> void:
	var viewport: SubViewport = get_node_or_null("%PreviewViewport")
	if viewport == null:
		return
	var root := Node3D.new()
	viewport.add_child(root)
	var camera := Camera3D.new()
	camera.position = Vector3(0, 7, 12)
	camera.rotation_degrees = Vector3(-32, 0, 0)
	camera.current = true
	root.add_child(camera)
	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-45, 35, 0)
	sun.light_energy = 2.0
	root.add_child(sun)
	_add_preview_box(root, Vector3(0, -0.05, 0), Vector3(24, 0.1, 16), Color(0.23, 0.48, 0.28))
	_add_preview_box(root, Vector3(0, 0.0, 0), Vector3(3.0, 0.12, 15), Color(0.32, 0.27, 0.21))
	for index: int in range(5):
		_add_preview_box(root, Vector3(-7.0 + index * 3.5, 0.8, -2.5), Vector3(2.2, 1.6, 1.8), Color(0.70, 0.52, 0.32))
		_add_preview_box(root, Vector3(-7.0 + index * 3.5, 1.75, -2.5), Vector3(2.5, 0.28, 2.1), Color(0.42, 0.16, 0.08))
	for index: int in range(14):
		var x: float = -10.5 + float(index % 7) * 3.5
		var z: float = 4.0 + float(index / 7) * 3.0
		_add_preview_box(root, Vector3(x, 0.65, z), Vector3(0.32, 1.3, 0.32), Color(0.35, 0.18, 0.08))
		_add_preview_sphere(root, Vector3(x, 1.55, z), Color(0.08, 0.42, 0.17))


func _add_preview_box(parent: Node3D, position: Vector3, size: Vector3, color: Color) -> void:
	var mesh := MeshInstance3D.new()
	var box := BoxMesh.new()
	box.size = size
	mesh.mesh = box
	mesh.position = position
	mesh.material_override = _preview_material(color)
	parent.add_child(mesh)


func _add_preview_sphere(parent: Node3D, position: Vector3, color: Color) -> void:
	var mesh := MeshInstance3D.new()
	var sphere := SphereMesh.new()
	sphere.radius = 0.85
	sphere.height = 1.3
	mesh.mesh = sphere
	mesh.position = position
	mesh.material_override = _preview_material(color)
	parent.add_child(mesh)


func _preview_material(color: Color) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	return material


func _select_character(character_id: String) -> void:
	SoundManager.play_ui()
	PlayerManager.select_character(character_id)
	_show_characters()


func _on_character_changed(character_data: Dictionary) -> void:
	var character_name: String = str(character_data.get("name", "Maica"))
	var character_description: String = str(character_data.get("description", ""))
	selected_character_label.text = "Personagem: %s" % character_name
	status_label.text = "%s selecionado. %s" % [character_name, character_description]
	_update_avatar(character_data)
	_refresh_character_buttons()


func _update_avatar(character_data: Dictionary) -> void:
	if avatar_frame == null or avatar_image == null:
		return
	var accent: Color = character_data.get("accent_color", Color(0.2, 0.5, 0.4))
	var style := StyleBoxFlat.new()
	style.bg_color = accent.darkened(0.45)
	style.border_color = accent
	style.set_border_width_all(2)
	style.set_corner_radius_all(10)
	style.set_content_margin_all(6)
	avatar_frame.add_theme_stylebox_override("panel", style)
	avatar_image.texture = IconManager.get_icon("person")
