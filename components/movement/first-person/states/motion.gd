class_name Motion extends State

signal gravity_enabled
signal gravity_disabled

@export_group("Gravity")
## The world gravity that it`s being applied to objects
@export var gravity: float = 60.0
## Enable or disable the gravity
@export var gravity_active := true:
	set(value):
		if value != gravity_active:
			if value:
				gravity_enabled.emit()
			else:
				gravity_disabled.emit()
				
		gravity_active = value
## The limit max velocity that can reach the actor when is falling
@export var fall_velocity_limit: float = 300.0

@export_group("Motion")
## The friction value for decelerate motion
@export var friction: float = 7.0

@export_group("Stair stepping")
## Define if the behaviour to step & down stairs it's enabled
@export var stair_stepping_enabled := true
## Maximum height in meters the player can step up.
@export var max_step_up := 0.5 
## Maximum height in meters the player can step down.
@export var max_step_down := -0.5
## Shortcut for converting vectors to vertical
@export var vertical := Vector3(0, 1, 0)
## Shortcut for converting vectors to horizontal
@export var horizontal := Vector3(1, 0, 1)


@onready var animation_player: AnimationPlayer = owner.get_node("AnimationPlayer")

var transformed_input := TransformedInput.new()

var is_grounded := true
var was_grounded := true

var stair_stepping := false


func physics_update(delta: float):
	was_grounded = is_grounded
	is_grounded = FSM.actor.is_on_floor()
	
	transformed_input.update_input_direction(FSM.actor as FirstPersonController)
	
	if gravity_active and not FSM.actor.is_on_floor() and not FSM.current_state_name_is("Jump"):
		FSM.actor.velocity.y -= gravity * delta

	if is_falling() and not stair_stepping:
		state_finished.emit("Fall", {})
		return
		
	
#

func is_falling() -> bool:
	return FSM.actor.velocity.y < 0 and was_grounded and not is_grounded and not FSM.current_state_name_is("Fall")


func move(speed: float, delta: float = get_physics_process_delta_time()):
	var world_coordinate_space_direction := transformed_input.world_coordinate_space_direction
	
	if world_coordinate_space_direction:
		FSM.actor.velocity.x = world_coordinate_space_direction.x * speed
		FSM.actor.velocity.z = world_coordinate_space_direction.z * speed
	else:
		# https://github.com/godotengine/godot/pull/73873
		FSM.actor.velocity.x = lerp(FSM.actor.velocity.x, world_coordinate_space_direction.x * speed, delta * friction)
		FSM.actor.velocity.z = lerp(FSM.actor.velocity.z, world_coordinate_space_direction.z * speed, delta * friction)


func stair_step_up():
	if not stair_stepping_enabled:
		return
		
	stair_stepping = false
	
	if transformed_input.world_coordinate_space_direction.is_zero_approx():
		return
	
	var body_test_params := PhysicsTestMotionParameters3D.new()
	var body_test_result := PhysicsTestMotionResult3D.new()
	var test_transform = FSM.actor.global_transform	 ## Storing current global_transform for testing
	var distance = transformed_input.world_coordinate_space_direction * 0.1	## Distance forward we want to check
	
	body_test_params.from =  FSM.actor.global_transform ## Self as origin point
	body_test_params.motion = distance ## Go forward by current distance

	# Pre-check: Are we colliding?
	if not PhysicsServer3D.body_test_motion(FSM.actor.get_rid(), body_test_params, body_test_result):
		return
	
	## 1- Move test transform to collision location
	var remainder = body_test_result.get_remainder() ## Get remainder from collision
	test_transform = test_transform.translated(body_test_result.get_travel()) ## Move test_transform by distance traveled before collision

	## 2. Move test_transform up to ceiling (if any)
	var step_up = max_step_up * vertical
	
	body_test_params.from = test_transform
	body_test_params.motion = step_up
	
	PhysicsServer3D.body_test_motion(FSM.actor.get_rid(), body_test_params, body_test_result)
	test_transform = test_transform.translated(body_test_result.get_travel())

	## 3. Move test_transform forward by remaining distance
	body_test_params.from = test_transform
	body_test_params.motion = remainder
	PhysicsServer3D.body_test_motion(FSM.actor.get_rid(), body_test_params, body_test_result)
	test_transform = test_transform.translated(body_test_result.get_travel())


	## 3.5 Project remaining along wall normal (if any). So you can walk into wall and up a step
	if body_test_result.get_collision_count() != 0:
		remainder = body_test_result.get_remainder().length()

		### Uh, there may be a better way to calculate this in Godot.
		var wall_normal = body_test_result.get_collision_normal()
		var dot_div_mag = transformed_input.world_coordinate_space_direction.dot(wall_normal) / (wall_normal * wall_normal).length()
		var projected_vector = (transformed_input.world_coordinate_space_direction - dot_div_mag * wall_normal).normalized()

		body_test_params.from = test_transform
		body_test_params.motion = remainder * projected_vector
		PhysicsServer3D.body_test_motion(FSM.actor.get_rid(), body_test_params, body_test_result)
		test_transform = test_transform.translated(body_test_result.get_travel())

	## 4. Move test_transform down onto step
	body_test_params.from = test_transform
	body_test_params.motion = max_step_up * -vertical
	
	## Return if no collision
	if not PhysicsServer3D.body_test_motion(FSM.actor.get_rid(), body_test_params, body_test_result):
		return
	
	test_transform = test_transform.translated(body_test_result.get_travel())
	
	## 5. Check floor normal for un-walkable slope
	var surface_normal = body_test_result.get_collision_normal()
	var temp_floor_max_angle = FSM.actor.floor_max_angle + deg_to_rad(20)
	
	if (snappedf(surface_normal.angle_to(vertical), 0.001) > temp_floor_max_angle):
		return
	
	stair_stepping = true
	# 6. Move player up
	var global_pos = FSM.actor.global_position
	#var step_up_dist = test_transform.origin.y - global_pos.y

	global_pos.y = test_transform.origin.y
	FSM.actor.global_position = global_pos

	
func stair_step_down():
	if not stair_stepping_enabled:
		return
		
	stair_stepping = false
	
	if FSM.actor.velocity.y <= 0 and was_grounded:
		## Initialize body test variables
		var body_test_result = PhysicsTestMotionResult3D.new()
		var body_test_params = PhysicsTestMotionParameters3D.new()

		body_test_params.from = FSM.actor.global_transform ## We get the player's current global_transform
		body_test_params.motion = Vector3(0, max_step_down, 0) ## We project the player downward

		if PhysicsServer3D.body_test_motion(FSM.actor.get_rid(), body_test_params, body_test_result):
			stair_stepping = true
			# Enters if a collision is detected by body_test_motion
			# Get distance to step and move player downward by that much
			FSM.actor.position.y += body_test_result.get_travel().y
			FSM.actor.apply_floor_snap()
			is_grounded = true


func detect_jump():
	if Input.is_action_just_pressed("jump") and FSM.actor.JUMP and (FSM.actor.is_on_floor() or FSM.current_state is WallRun):
		state_finished.emit("Jump", {})


func detect_crouch():
	if Input.is_action_pressed("crouch") and FSM.actor.is_on_floor() and FSM.actor.CROUCH:
		state_finished.emit("Crouch", {})


func detect_crawl():
	if Input.is_action_pressed("crawl") and FSM.actor.is_on_floor() and FSM.actor.CRAWL:
		state_finished.emit("Crawl", {})


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
