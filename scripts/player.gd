extends CharacterBody3D

signal interacted(data: Variant)
signal action_requested(action: String, position: Vector3)

@export var speed := 6.0
@export var gravity := -22.0
@export var mouse_sensitivity := 0.003
@export var proximity_interaction_radius := 4.0

@onready var camera_pivot: Node3D = $CameraPivot
@onready var interaction_ray: RayCast3D = $CameraPivot/Camera3D/InteractionRay

var _pitch := -0.2
var player_name := "Joaquim"
var _walk_time := 0.0
var _base_y := 0.0


func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	_base_y = position.y
	_apply_character(PlayerManager.get_selected_character())
	if has_node("NameLabel"):
		$NameLabel.text = player_name


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		rotate_y(-event.relative.x * mouse_sensitivity)
		_pitch = clamp(_pitch - event.relative.y * mouse_sensitivity, -0.85, 0.35)
		camera_pivot.rotation.x = _pitch
	if event.is_action_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	if event is InputEventMouseButton and event.pressed:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	if event.is_action_pressed("interact"):
		_interact()
		if event is InputEventKey and event.pressed and not event.echo:
			if event.keycode >= KEY_1 and event.keycode <= KEY_5:
				var tool_ids: Array = ["axe", "hammer", "saw", "collector", "first_aid"]
				var index: int = int(event.keycode - KEY_1)
				ToolManager.select_tool(str(tool_ids[index]))
			if event.keycode == KEY_B:
				action_requested.emit("open_build_menu", _get_action_position())
			if event.keycode == KEY_T:
				action_requested.emit("plant_tree", _get_action_position())
		if event.keycode == KEY_C:
			action_requested.emit("toggle_shop", global_position)


func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y += gravity * delta
	else:
		velocity.y = 0.0

	var input := Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	var direction := (global_transform.basis * Vector3(input.x, 0, input.y)).normalized()

	if direction.length() > 0.0:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
		_animate_walk(delta)
	else:
		velocity.x = move_toward(velocity.x, 0.0, speed)
		velocity.z = move_toward(velocity.z, 0.0, speed)
		_reset_walk_pose(delta)

	move_and_slide()


func _interact() -> void:
	interaction_ray.force_raycast_update()
	var target: Object = null
	if interaction_ray.is_colliding():
		target = interaction_ray.get_collider()

	if not target or not target.has_method("interact"):
		target = _find_nearest_interactable()

		if target and target.has_method("interact"):
			var result: Variant = target.interact(self)
			if typeof(result) == TYPE_STRING and result != "":
				interacted.emit(result)
			elif typeof(result) == TYPE_DICTIONARY:
				interacted.emit(result)
	else:
		interacted.emit("👀 Aproxime-se de uma pessoa, casa, agua, jardim ou missao.")


func _find_nearest_interactable() -> Node:
	var nearest: Node = null
	var nearest_distance := proximity_interaction_radius
	for node in get_tree().get_nodes_in_group("interactable"):
		if not node is Node3D:
			continue
		var distance := global_position.distance_to((node as Node3D).global_position)
		if distance < nearest_distance:
			nearest_distance = distance
			nearest = node
	return nearest


func _get_action_position() -> Vector3:
	interaction_ray.force_raycast_update()
	if interaction_ray.is_colliding():
		var point := interaction_ray.get_collision_point()
		return Vector3(point.x, 0.0, point.z)
	var forward := -global_transform.basis.z.normalized()
	var point := global_position + forward * 4.0
	return Vector3(point.x, 0.0, point.z)


func _apply_character(character: Dictionary) -> void:
	player_name = character.name
	var is_woman: bool = str(character.get("sex", "")) == "Mulher"
	_set_mesh_color("Torso", character.shirt_color)
	_set_mesh_color("Jacket", character.accent_color)
	_set_mesh_color("LeftLeg", character.pants_color)
	_set_mesh_color("RightLeg", character.pants_color)
	if has_node("Model/Hair"):
		$Model/Hair.scale = character.hair_scale
	if has_node("Model/LongHair"):
		var has_long_hair := str(character.get("hair_label", "")) == "cabelo longo"
		$Model/LongHair.visible = has_long_hair
		$Model/LongHair.scale = Vector3(1.0, 1.0, 1.0) if has_long_hair else Vector3.ONE
	if bool(character.get("has_capulana", false)) or is_woman:
		$Model/Jacket.scale = Vector3(1.04, 1.24, 1.03)
		$Model/Jacket.position.y = 0.95
		_ensure_skirt(character.accent_color)
		$Model/LeftLeg.scale = Vector3(0.82, 0.74, 0.82)
		$Model/RightLeg.scale = Vector3(0.82, 0.74, 0.82)
	else:
		$Model/Jacket.scale = Vector3.ONE
		$Model/Jacket.position.y = 1.15
		_hide_skirt()
		$Model/LeftLeg.scale = Vector3.ONE
		$Model/RightLeg.scale = Vector3.ONE


func _set_mesh_color(node_name: String, color: Color) -> void:
	var node := get_node_or_null("Model/%s" % node_name)
	if node == null or not node is MeshInstance3D:
		return
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	(node as MeshInstance3D).material_override = material


func celebrate() -> void:
	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(self, "position:y", position.y + 0.75, 0.18).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property($Model/LeftArm, "rotation_degrees:z", -125.0, 0.18)
	tween.tween_property($Model/RightArm, "rotation_degrees:z", 125.0, 0.18)
	tween.chain().tween_property(self, "position:y", position.y, 0.22).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	tween.parallel().tween_property($Model/LeftArm, "rotation_degrees:z", -10.0, 0.22)
	tween.parallel().tween_property($Model/RightArm, "rotation_degrees:z", 10.0, 0.22)


func _animate_walk(delta: float) -> void:
	_walk_time += delta * 8.0
	var sway: float = sin(_walk_time) * 18.0
	$Model/LeftArm.rotation_degrees.z = -10.0 - sway
	$Model/RightArm.rotation_degrees.z = 10.0 + sway
	$Model/LeftLeg.rotation_degrees.x = sway * 0.75
	$Model/RightLeg.rotation_degrees.x = -sway * 0.75


func _reset_walk_pose(delta: float) -> void:
	$Model/LeftArm.rotation_degrees.z = lerpf($Model/LeftArm.rotation_degrees.z, -10.0, delta * 8.0)
	$Model/RightArm.rotation_degrees.z = lerpf($Model/RightArm.rotation_degrees.z, 10.0, delta * 8.0)
	$Model/LeftLeg.rotation_degrees.x = lerpf($Model/LeftLeg.rotation_degrees.x, 0.0, delta * 8.0)
	$Model/RightLeg.rotation_degrees.x = lerpf($Model/RightLeg.rotation_degrees.x, 0.0, delta * 8.0)


func _ensure_skirt(color: Color) -> void:
	var skirt := get_node_or_null("Model/Skirt") as MeshInstance3D
	if skirt == null:
		skirt = MeshInstance3D.new()
		skirt.name = "Skirt"
		var mesh := CylinderMesh.new()
		mesh.top_radius = 0.36
		mesh.bottom_radius = 0.52
		mesh.height = 0.72
		skirt.mesh = mesh
		skirt.position = Vector3(0, 0.66, 0)
		$Model.add_child(skirt)
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	skirt.material_override = material
	skirt.visible = true


func _hide_skirt() -> void:
	var skirt := get_node_or_null("Model/Skirt")
	if skirt:
		skirt.visible = false
