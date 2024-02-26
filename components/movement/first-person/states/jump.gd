class_name JumpFirstPerson extends Motion

@export var air_control_speed := 2.5
## The times this actor can jump
@export var jump_times := 1
@export var jump_height: float:
	set(value):
		jump_height = value
		if is_node_ready():
			jump_velocity = _calculate_jump_velocity(jump_height)
		
@export var jump_time_to_peak: float:
	set(value):
		jump_time_to_peak = value
		if is_node_ready():
			jump_gravity = _calculate_jump_gravity(jump_height, jump_time_to_peak)
		
@export var jump_time_to_fall: float:
	set(value):
		jump_time_to_fall = value
		if is_node_ready():
			fall_gravity = _calculate_fall_gravity(jump_height, jump_time_to_fall)
@export var override_jump_gravity := 0.0
@export var override_fall_gravity := 0.0

var jump_velocity: float
var jump_gravity: float
var fall_gravity: float

var jump_count = 1


func _enter():
	jump_velocity = _calculate_jump_velocity()
	jump_gravity = _calculate_jump_gravity()
	fall_gravity = _calculate_fall_gravity()
	
	FSM.actor.velocity.y = jump_velocity
	FSM.actor.move_and_slide()

func _exit(_next_state: State):
	jump_count = 1
	
	
func physics_update(delta: float):
	super.physics_update(delta)
	
	if FSM.actor.is_on_floor():
		if transformed_input.input_direction.is_zero_approx():
			state_finished.emit("Idle", {})
		else:
			state_finished.emit("Walk", {})
	else:
		if FSM.actor.velocity.y > 0:
			FSM.actor.velocity.y -= jump_gravity * delta
		else:
			FSM.actor.velocity.y -= fall_gravity * delta
			
	FSM.actor.velocity.x = lerp(FSM.actor.velocity.x, transformed_input.world_coordinate_space_direction.x * air_control_speed, delta)
	FSM.actor.velocity.z = lerp(FSM.actor.velocity.z, transformed_input.world_coordinate_space_direction.z * air_control_speed, delta)

	if Input.is_action_just_pressed("jump") and jump_times > 1 and jump_count < jump_times:
		FSM.actor.velocity.y = jump_velocity
		jump_count += 1
		
	#if Input.is_action_just_released("jump"):
		#shorten_jump()
	
	FSM.actor.move_and_slide()
	

func shorten_jump():
	var new_jump_velocity = jump_velocity / 2

	if FSM.actor.velocity.y > new_jump_velocity:
		FSM.actor.velocity.y = new_jump_velocity


func _calculate_jump_velocity(_jump_height: float = jump_height, time_to_peak: float = jump_time_to_peak):
	return 2.0 * _jump_height / (time_to_peak * FSM.actor.up_direction.y)


func _calculate_jump_gravity(_jump_height: float = jump_height, time_to_peak: float = jump_time_to_peak):
	return override_jump_gravity if override_jump_gravity > 0 else 2.0 * _jump_height / (pow(time_to_peak, 2))
	
	
func _calculate_fall_gravity(_jump_height: float = jump_height, time_to_fall: float = jump_time_to_fall):
	return override_fall_gravity if override_fall_gravity > 0 else 2.0 * _jump_height / (pow(time_to_fall, 2))
