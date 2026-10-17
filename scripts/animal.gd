extends CharacterBody3D

@export var animal_kind := "chicken"
@export var animal_label := "Animal"
@export var walk_radius := 4.0
@export var walk_speed := 0.8

var home_position := Vector3.ZERO
var target_position := Vector3.ZERO
var wait_time := 0.0
var rng := RandomNumberGenerator.new()


func _ready() -> void:
	rng.randomize()
	call_deferred("_setup_home")


func _setup_home() -> void:
	home_position = global_position
	_pick_target()


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
	if to_target.length() < 0.25:
		wait_time = rng.randf_range(1.2, 4.5)
		_pick_target()
		return

	var direction := to_target.normalized()
	velocity.x = direction.x * walk_speed
	velocity.z = direction.z * walk_speed
	if not is_on_floor():
		velocity.y -= 20.0 * delta
	else:
		velocity.y = 0.0
	look_at(Vector3(target_position.x, global_position.y, target_position.z), Vector3.UP)
	move_and_slide()


func _pick_target() -> void:
	target_position = home_position + Vector3(
		rng.randf_range(-walk_radius, walk_radius),
		0.0,
		rng.randf_range(-walk_radius, walk_radius)
	)


func interact(_player: Node) -> String:
	wait_time = rng.randf_range(2.0, 4.0)
	velocity = Vector3.ZERO
	match animal_kind:
		"chicken":
			return "🐔 Uma galinha! As galinhas dao ovos e sao importantes para a alimentacao da comunidade."
		"dog":
			return "🐕 Um cao guardiao! Ele protege as casas e os habitantes da comunidade."
		"ox":
			return "🐄 Um boi. Os bois ajudam nos campos e sao essenciais para a agricultura."
		"goat":
			return "🐐 Um cabrito. Os cabritos dao leite e sao importantes para a comunidade."
	return "🐾 Um animal da comunidade."
