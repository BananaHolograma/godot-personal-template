class_name FirstPersonController extends CharacterBody3D

@export_group("Mechanics")
@export var JUMP := true
@export var WALL_JUMP := false
## RUN needs to be active also to use the slide
@export var RUN := true
@export var WALL_RUN := false
@export var SLIDE := false
@export var CROUCH := true
@export var CRAWL := true

@onready var finite_state_machine: FiniteStateMachine = $FiniteStateMachine
@onready var camera: Camera3D = %Camera3D
@onready var head: Node3D = $Head
@onready var ceil_shape_detector: ShapeCast3D = %CeilShapeCast
@onready var stand_collision_shape: CollisionShape3D = $StandCollisionShape
@onready var crouch_collision_shape: CollisionShape3D = $CrouchCollisionShape
@onready var crawl_collision_shape: CollisionShape3D = $CrawlCollisionShape

## TODO - GET VALUES FROM GAME SETTINGS SAVED GAME
@export_group("Camera parameters")
## The camera sensitivity to balance the smoothness of the rotation
@export_range(0, 1, 0.01) var camera_sensitivity := 0.45
## The mouse sensitivity to adjust the speed of the mouse movement applied to the camera or world in general
@export var mouse_sensitivity := 3.0
## The limit where the camera can rotate relative to x-axis(up-down), by default it's 90 degrees or PI / 2
@export var camera_rotation_limit := PI / 2

var locked := false

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
	GameEvents.lock_player.connect(lock_player.bind(true))
	GameEvents.unlock_player.connect(lock_player.bind(false))
	
	finite_state_machine.state_changed.connect(on_state_changed)


func _unhandled_input(event: InputEvent):
	if not locked and event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		rotate_camera(event.relative.x, event.relative.y)
		
	if Input.is_action_just_pressed("ui_cancel"):
		_switch_mouse_mode()


func rotate_camera(relative_x: float, relative_y: float):
	var twist_input = relative_x / 1000 * mouse_sensitivity 
	var pitch_input = relative_y / 1000 * mouse_sensitivity 
	
	var target_rotation_y = rotation.y - twist_input # Body rotation
	var target_rotation_x = head.rotation.x - pitch_input # Head & Neck rotation
	target_rotation_x = clamp(target_rotation_x , -camera_rotation_limit, camera_rotation_limit)
	
	rotation.y =  lerp_angle(rotation.y, target_rotation_y, camera_sensitivity)
	head.rotation.x = lerp_angle(head.rotation.x, target_rotation_x, camera_sensitivity)


func update_collisions(current_state: State):
	match current_state.name:
		"Idle", "Walk":
			stand_collision_shape.disabled = false
			crouch_collision_shape.disabled = true
			crawl_collision_shape.disabled = true
		"Crouch", "Slide":
			stand_collision_shape.disabled = true
			crouch_collision_shape.disabled = false
			crawl_collision_shape.disabled = true
		"Crawl":
			stand_collision_shape.disabled = true
			crouch_collision_shape.disabled = true
			crawl_collision_shape.disabled = false
		_:
			stand_collision_shape.disabled = false
			crouch_collision_shape.disabled = true
			crawl_collision_shape.disabled = true
			
			
## TODO - SET WHERE TO LOCK THE MOVEMENT
func lock_player(lock : bool) -> void:
	if lock:
		locked = true
		#finite_state_machine.lock_state_machine()
	else:
		locked = false
		#finite_state_machine.unlock_state_machine()


func _switch_mouse_mode() -> void:
	if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	else:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

### SIGNAL CALLBACKS ###
func on_state_changed(_previous: State, _current: State):
	update_collisions(_current)
