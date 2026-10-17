extends CharacterBody3D

@export var npc_name := "Habitante"
@export var npc_type := "NPC_HOMEM_INFORMAL"
@export var sex := "Homem"
@export var age := 30
@export var clothing := "Roupa informal"
@export var profession := "Morador"
@export var home := "Casa"
@export var state := "Precisa de ajuda"
@export var dialogue := "Precisamos de ajuda na comunidade."
@export var mission_id := "find_water"
@export var walk_radius := 4.0
@export var walk_speed := 1.4

var home_position := Vector3.ZERO
var target_position := Vector3.ZERO
var wait_time := 0.0
var rng := RandomNumberGenerator.new()
var _walk_time := 0.0


func _ready() -> void:
	rng.randomize()
	add_to_group("interactable")
	_apply_type()
	call_deferred("_setup_home")


func _setup_home() -> void:
	home_position = global_position
	target_position = home_position
	_refresh_label()


func _physics_process(delta: float) -> void:
	if home_position == Vector3.ZERO:
		return

	if wait_time > 0.0:
		wait_time -= delta
		velocity.x = move_toward(velocity.x, 0.0, walk_speed)
		velocity.z = move_toward(velocity.z, 0.0, walk_speed)
		move_and_slide()
		return

	var flat_position := Vector3(global_position.x, 0.0, global_position.z)
	var flat_target := Vector3(target_position.x, 0.0, target_position.z)
	var to_target := flat_target - flat_position

	if to_target.length() < 0.35:
		wait_time = rng.randf_range(1.4, 3.8)
		target_position = home_position + Vector3(
			rng.randf_range(-walk_radius, walk_radius),
			0.0,
			rng.randf_range(-walk_radius, walk_radius)
		)
		return

	var direction := to_target.normalized()
	velocity.x = direction.x * walk_speed
	velocity.z = direction.z * walk_speed
	_animate_walk(delta)
	if not is_on_floor():
		velocity.y -= 20.0 * delta
	else:
		velocity.y = 0.0
	look_at(Vector3(target_position.x, global_position.y, target_position.z), Vector3.UP)
	move_and_slide()


func get_prompt(_player: Node) -> String:
	return "E — Falar com %s" % npc_name


func interact(_player: Node) -> Dictionary:
	wait_time = 4.0
	velocity = Vector3.ZERO
	if _player is Node3D:
		var player_position := (_player as Node3D).global_position
		look_at(Vector3(player_position.x, global_position.y, player_position.z), Vector3.UP)
	return {
		"type": "npc",
		"npc": self,
		"name": npc_name,
		"profession": profession,
		"clothing": clothing,
		"dialogue": dialogue,
		"state": state,
		"home": home,
		"mission_id": mission_id
	}


func _refresh_label() -> void:
		$NameLabel.text = "%s\n%s" % [npc_name, profession]


func _apply_type() -> void:
	var data := NPCManager.get_type_data(npc_type)
	sex = data.sex
	clothing = data.clothing
	scale = data.get("scale", Vector3.ONE)
	_set_mesh_color("Torso", data.shirt_color)
	_set_mesh_color("Vest", data.accent_color)
	_set_mesh_color("LeftLeg", data.pants_color)
	_set_mesh_color("RightLeg", data.pants_color)
	if has_node("Model/Hair"):
		$Model/Hair.scale = data.hair_scale
	if npc_type == "NPC_MULHER_CAPULANA" or npc_type == "NPC_MULHER_INFORMAL":
		var vest_node := get_node_or_null("Model/Vest")
		if vest_node and vest_node is MeshInstance3D:
			vest_node.scale = Vector3(1.05, 1.28, 1.0)
			vest_node.position.y = 0.91
		_ensure_skirt(data.accent_color)
		$Model/LeftLeg.scale = Vector3(0.82, 0.72, 0.82)
		$Model/RightLeg.scale = Vector3(0.82, 0.72, 0.82)
	else:
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


func _animate_walk(delta: float) -> void:
	_walk_time += delta * 5.0
	var sway: float = sin(_walk_time) * 12.0
	$Model/LeftArm.rotation_degrees.z = -10.0 - sway
	$Model/RightArm.rotation_degrees.z = 10.0 + sway
	$Model/LeftLeg.rotation_degrees.x = sway * 0.45
	$Model/RightLeg.rotation_degrees.x = -sway * 0.45


func _ensure_skirt(color: Color) -> void:
	var skirt := get_node_or_null("Model/Skirt") as MeshInstance3D
	if skirt == null:
		skirt = MeshInstance3D.new()
		skirt.name = "Skirt"
		var mesh := CylinderMesh.new()
		mesh.top_radius = 0.34
		mesh.bottom_radius = 0.50
		mesh.height = 0.66
		skirt.mesh = mesh
		skirt.position = Vector3(0, 0.62, 0)
		$Model.add_child(skirt)
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	skirt.material_override = material
	skirt.visible = true


func _hide_skirt() -> void:
	var skirt := get_node_or_null("Model/Skirt")
	if skirt:
		skirt.visible = false
