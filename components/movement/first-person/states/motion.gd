class_name Motion extends State

signal gravity_enabled
signal gravity_disabled

## The world gravity that it`s being applied to objects
@export var gravity := ProjectSettings.get_setting("physics/3d/default_gravity") as float
## Enable or disable the gravity
@export var gravity_active := true:
	set(value):
		if value != gravity_active:
			if value:
				gravity_enabled.emit()
			else:
				gravity_disabled.emit()
				
		gravity_active = value
## The friction value for decelerate motion
@export var friction: float = 7.0
## The limit max velocity that can reach the actor when is falling
@export var fall_velocity_limit: float = 300.0

var transformed_input := TransformedInput.new()


func physics_update(delta: float):
	transformed_input.update_input_direction(FSM.actor as CharacterBody3D)
	
		
	if gravity_active and not FSM.actor.is_on_floor():
		FSM.actor.velocity.y -= gravity * delta
	

func move(speed: float, delta: float = get_physics_process_delta_time()):
	var world_coordinate_space_direction := transformed_input.world_coordinate_space_direction
	
	if world_coordinate_space_direction:
		FSM.actor.velocity.x = world_coordinate_space_direction.x * speed
		FSM.actor.velocity.z = world_coordinate_space_direction.z * speed
	else:
		# https://github.com/godotengine/godot/pull/73873
		FSM.actor.velocity.x = lerp(FSM.actor.velocity.x, world_coordinate_space_direction.x * speed, delta * friction)
		FSM.actor.velocity.z = lerp(FSM.actor.velocity.z, world_coordinate_space_direction.z * speed, delta * friction)


func enable_gravity():
	gravity_active = true


func disable_gravity():
	gravity_active = false


class TransformedInput:
	## Raw input vector from user key presses
	var input_direction: Vector2
	## Movement direction transformed into world space
	var world_coordinate_space_direction: Vector3
	
	func update_input_direction(actor: CharacterBody3D) -> void:
		input_direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
		world_coordinate_space_direction = (actor.transform.basis * Vector3(input_direction.x, 0, input_direction.y)).normalized()	

