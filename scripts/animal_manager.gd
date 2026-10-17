extends Node

const ANIMALS := {
	"chicken": {
		"label": "🐔 Galinha",
		"body_color": Color(0.93, 0.86, 0.62),
		"accent_color": Color(0.86, 0.12, 0.08),
		"size": Vector3(0.42, 0.34, 0.5),
		"speed": 0.9,
		"radius": 3.2
	},
	"dog": {
		"label": "🐕 Cao",
		"body_color": Color(0.45, 0.28, 0.15),
		"accent_color": Color(0.9, 0.86, 0.7),
		"size": Vector3(0.75, 0.42, 1.0),
		"speed": 1.15,
		"radius": 4.5
	},
	"ox": {
		"label": "🐄 Boi",
		"body_color": Color(0.42, 0.31, 0.22),
		"accent_color": Color(0.92, 0.88, 0.76),
		"size": Vector3(1.35, 0.78, 1.75),
		"speed": 0.65,
		"radius": 6.0
	},
	"goat": {
		"label": "🐐 Cabrito",
		"body_color": Color(0.78, 0.72, 0.62),
		"accent_color": Color(0.28, 0.22, 0.16),
		"size": Vector3(0.75, 0.5, 1.0),
		"speed": 0.85,
		"radius": 5.0
	}
}


func create_animal(kind: String) -> CharacterBody3D:
	var data: Dictionary = ANIMALS.get(kind, ANIMALS.chicken)
	var animal := CharacterBody3D.new()
	animal.name = "%sAnimal" % kind.capitalize()
	animal.set_script(load("res://scripts/animal.gd"))
	animal.animal_kind = kind
	animal.animal_label = data.label
	animal.walk_speed = float(data.speed)
	animal.walk_radius = float(data.radius)
	animal.add_to_group("interactable")

	var collision := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = data.size
	collision.shape = shape
	collision.position.y = data.size.y * 0.5
	animal.add_child(collision)

	var body := MeshInstance3D.new()
	var body_mesh := BoxMesh.new()
	body_mesh.size = data.size
	body.mesh = body_mesh
	body.position.y = data.size.y * 0.5
	body.material_override = _material(data.body_color)
	animal.add_child(body)

	var head := MeshInstance3D.new()
	var head_mesh := BoxMesh.new()
	head_mesh.size = data.size * Vector3(0.42, 0.62, 0.38)
	head.mesh = head_mesh
	head.position = Vector3(0, data.size.y * 0.78, -data.size.z * 0.55)
	head.material_override = _material(data.accent_color)
	animal.add_child(head)

	var label := Label3D.new()
	label.name = "Label3D"
	label.text = data.label
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label.position.y = data.size.y + 0.55
	animal.add_child(label)

	return animal


func _material(color: Color) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	return material
