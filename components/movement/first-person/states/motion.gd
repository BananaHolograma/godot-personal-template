class_name Motion extends State

@export var friction: float = 7.0
@export var fall_velocity_limit: float = 300.0

var transformed_input := TransformedInput.new()


func physics_update(delta: float):
	transformed_input.update_input_direction(FSM.actor as CharacterBody3D)
	

func move(speed: float, delta: float = get_physics_process_delta_time()):
	var world_coordinate_space_direction := transformed_input.world_coordinate_space_direction
	
	if world_coordinate_space_direction:
		FSM.actor.velocity.x = world_coordinate_space_direction.x * speed
		FSM.actor.velocity.z = world_coordinate_space_direction.z * speed
	else:
		# https://github.com/godotengine/godot/pull/73873
		FSM.actor.velocity.x = lerp(FSM.actor.velocity.x, world_coordinate_space_direction.x * speed, delta * friction)
		FSM.actor.velocity.z = lerp(FSM.actor.velocity.z, world_coordinate_space_direction.z * speed, delta * friction)


class TransformedInput:
	## Raw input vector from user key presses
	var input_direction: Vector2
	## Movement direction transformed into world space
	var world_coordinate_space_direction: Vector3
	
	func update_input_direction(actor: CharacterBody3D) -> void:
		input_direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
		world_coordinate_space_direction = (actor.transform.basis * Vector3(input_direction.x, 0, input_direction.y)).normalized()	

