class_name Destruction extends Node

@export var target: Node3D
@export var shards_container: Node3D


func _input(event):
	if Input.is_action_just_pressed("ui_accept"):
		destroy()
		
		
func destroy():
	target.hide()
	for i in range(150):
		create_shard()


func create_shard():
	var body := RigidBody3D.new()
	var _mesh := MeshInstance3D.new()
	var shape := CollisionShape3D.new()
	shape.shape = BoxShape3D.new()

	body.add_child(_mesh)
	body.add_child(shape)
	_mesh.mesh = BoxMesh.new()
	_mesh.mesh.size = Vector3(randf_range(0.1, 0.2), randf_range(0.1, 0.2), randf_range(0.1, 0.2))
	shape.shape.size = _mesh.mesh.size
	
	if shards_container == null:
		get_tree().root.add_child(body)
	else:
		shards_container.add_child(body, true)
	body.global_position = target.global_transform.origin + body.position
	body.global_rotation = target.global_rotation
	
	#body.linear_velocity = Vector3(randi_range(-1, 1), randi_range(-1, 1), randi_range(-1, 1)) * 10
	body.apply_impulse(_random_direction() * randi_range(20, 40), -body.position.normalized())

	

static func _random_direction() -> Vector3:
	return (Vector3(randf(), randf(), randf()) - Vector3.ONE / 2.0).normalized() * 2.0
