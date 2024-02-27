class_name WallRun extends Motion

## The camera rotation to simulate actor is holding in the wall
@export var camera_rotation_angle := 0.15
## The gravity applied on wall run, set to zero to disable it
@export var wall_gravity := 1.5
## The speed while running on the wall
@export var speed := 3.0
## Initial boost when wall run is entered
@export var initial_boost_speed := 2.0

var right_wall_detector: RayCast3D 
var front_wall_detector: RayCast3D
var left_wall_detector: RayCast3D


enum WALL {
	RIGHT,
	LEFT,
	FRONT
}

var wall_normal := Vector3.ZERO
var current_wall := WALL.LEFT
var direction := Vector3.ZERO

func _enter():
	if right_wall_detector == null:
		right_wall_detector = FSM.actor.get_node("RightWallDetector")
	
	if front_wall_detector == null:
		front_wall_detector = FSM.actor.get_node("FrontWallDetector")
		
	if left_wall_detector == null:
		left_wall_detector = FSM.actor.get_node("LeftWallDetector")

	FSM.actor.velocity +=  initial_boost_speed * Vector3.FORWARD.rotated(Vector3.UP, FSM.actor.global_transform.basis.get_euler().y).normalized()
	
	wall_normal = get_wall_normal(params)
	
	rotate_camera_based_on_normal(wall_normal)


func _exit(_next_state: State):
	var tween: Tween = create_tween()
	tween.tween_property(FSM.actor.eyes, "rotation:z", 0, 0.3).set_trans(Tween.TRANS_CUBIC)
	
	wall_normal = Vector3.ZERO
	params = {}


func physics_update(delta: float):
	transformed_input.update_input_direction(FSM.actor as FirstPersonController)
	
	if FSM.actor.is_on_floor():
		if transformed_input.input_direction.is_zero_approx():
			state_finished.emit("Idle", {})
			return
		else:
			state_finished.emit("Walk", {})
			return
	else:
		if wall_gravity > 0:
			FSM.actor.velocity.y -= wall_gravity * delta
	
	if not wall_detected():
		state_finished.emit("Fall", {})
		return
		
	FSM.actor.move_and_slide()

	if FSM.actor.WALL_JUMP:
		detect_jump()
	

func wall_detected() -> bool:
	return not FSM.actor.is_on_floor() and (right_wall_detector.is_colliding() or left_wall_detector.is_colliding() or front_wall_detector.is_colliding())


## Wall params has the next example structure:
## {"right_wall": (0, 0, 0), "left_wall":(-1, 0, 0), "front_wall":(0, 0, 0)}
func get_wall_normal(params: Dictionary) -> Vector3:
	for wall in params.keys():
		
		var normal = params[wall] as Vector3
		
		if not normal.is_zero_approx():
			match wall:
				"right_wall":
					current_wall = WALL.RIGHT
				"left_wall":
					current_wall = WALL.LEFT
				"front_wall":
					current_wall = WALL.FRONT
					
			wall_normal = params[wall]
			break
			
	return wall_normal


func get_move_direction_on_wall() -> Vector3:
	direction = transformed_input.world_coordinate_space_direction.slide(wall_normal)
	direction -= wall_normal
	
	return direction
	
	
func rotate_camera_based_on_normal(wall_normal: Vector3):
	if wall_normal.is_zero_approx():
		return
	
	var rotation =  camera_rotation_angle
	
	match current_wall:
		WALL.RIGHT:
			rotation *= 1
		WALL.LEFT:
			rotation *= -1
		WALL.FRONT:
			rotation = 0
	
	var tween: Tween = create_tween()
	tween.tween_property(FSM.actor.eyes, "rotation:z", rotation, 0.3).set_trans(Tween.TRANS_CUBIC)
