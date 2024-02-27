class_name JumpFirstPerson extends Motion

## When the velocity.y negative is greater than this value, the fall state will be triggered
@export var velocity_barrier_to_fall := -15
## The amount of speed applied when control the actor in the air
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

@export_group("Wall run")
## After this frames passed the wall detection becomes active to avoid block the jump suddenly for the player
@export var wall_detection_after_frames := 25.0


var jump_velocity: float
var jump_gravity: float
var fall_gravity: float

var jump_count = 1

var right_wall_detector: RayCast3D 
var front_wall_detector: RayCast3D
var left_wall_detector: RayCast3D

var wall_detection_active := false
var wall_detection_timer: Timer

func _enter():
	if right_wall_detector == null:
		right_wall_detector = FSM.actor.get_node("RightWallDetector")
	
	if front_wall_detector == null:
		front_wall_detector = FSM.actor.get_node("FrontWallDetector")
		
	if left_wall_detector == null:
		left_wall_detector = FSM.actor.get_node("LeftWallDetector")

	
	jump_velocity = _calculate_jump_velocity()
	jump_gravity = _calculate_jump_gravity()
	fall_gravity = _calculate_fall_gravity()
	
	FSM.actor.velocity.y = jump_velocity
	FSM.actor.move_and_slide()
	
	wall_detection_timer.start()


func _create_wall_detection_timer() -> void:
	wall_detection_timer = Timer.new()
	wall_detection_timer.name = "WallDetectionTimer"
	wall_detection_timer.wait_time = wall_detection_after_frames / Engine.physics_ticks_per_second
	wall_detection_timer.process_callback = Timer.TIMER_PROCESS_PHYSICS
	wall_detection_timer.autostart = false
	wall_detection_timer.one_shot = true
	
	add_child(wall_detection_timer)
	wall_detection_timer.timeout.connect(func(): wall_detection_active = true)


func _ready():
	_create_wall_detection_timer()


func _exit(_next_state: State):
	jump_count = 1
	wall_detection_active = false
	
	
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
			
			if velocity_barrier_to_fall < 0 and FSM.actor.velocity.y < velocity_barrier_to_fall:
				state_finished.emit("Fall", {})
				
	FSM.actor.velocity.x = lerp(FSM.actor.velocity.x, transformed_input.world_coordinate_space_direction.x * air_control_speed, delta)
	FSM.actor.velocity.z = lerp(FSM.actor.velocity.z, transformed_input.world_coordinate_space_direction.z * air_control_speed, delta)

	if Input.is_action_just_pressed("jump") and jump_times > 1 and jump_count < jump_times:
		FSM.actor.velocity.y = jump_velocity
		jump_count += 1
	
	if FSM.actor.WALL_RUN and wall_detection_active and wall_detected():
		state_finished.emit("WallRun", {
			"right_wall": right_wall_detector.get_collision_normal() if right_wall_detector.is_colliding() else Vector3.ZERO, 
			"left_wall": left_wall_detector.get_collision_normal() if left_wall_detector.is_colliding() else Vector3.ZERO,
			"front_wall": front_wall_detector.get_collision_normal() if front_wall_detector.is_colliding() else Vector3.ZERO
		})
		
		return

	FSM.actor.move_and_slide()


func wall_detected() -> bool:
	return not FSM.actor.is_on_floor() and (right_wall_detector.is_colliding() or left_wall_detector.is_colliding() or front_wall_detector.is_colliding())


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
