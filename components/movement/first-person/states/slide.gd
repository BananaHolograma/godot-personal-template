class_name SlideFirstPerson extends Motion

@export var speed := 4.5
@export var slide_time := 1.2
## This applies a momentum on the last part of the slide to continue the movement
@export var friction_momentum := 0.1
## The angle in degrees you want to apply on slide motion
@export var slide_tilt := 5.0


var slide_timer: Timer
var last_direction: Vector3 = Vector3.ZERO
var decrease_rate := slide_time
var slide_side: int


func _enter():
	slide_timer.start()
	transformed_input.update_input_direction(FSM.actor)
	last_direction = transformed_input.world_coordinate_space_direction
	decrease_rate = slide_time
	animation_player.play("crouch")
	slide_side = sign(randi_range(-1, 1))
	
	
func _exit(next_state: State) -> void:
	slide_timer.stop();
	decrease_rate = slide_time
	FSM.actor.head.rotation.z = 0.0
	
	if next_state is JumpFirstPerson:
		animation_player.play_backwards("crouch")


func _ready():
	_create_slide_timer()
	
	
func physics_update(delta):	
	decrease_rate -= delta
	FSM.actor.velocity.x = last_direction.x * (decrease_rate + friction_momentum) * speed
	FSM.actor.velocity.z = last_direction.z * (decrease_rate + friction_momentum) * speed
	
	if slide_tilt > 0:
		FSM.actor.head.rotation.z = lerp(FSM.actor.head.rotation.z, slide_side * deg_to_rad(slide_tilt), delta * 8.0)
	
	if not FSM.actor.ceil_shape_detector.is_colliding():
		detect_jump()
	
	FSM.actor.move_and_slide()
	

func _create_slide_timer() -> void:
	slide_timer = Timer.new()
	slide_timer.name = "SlideTimer"
	slide_timer.wait_time = slide_time
	slide_timer.process_callback = Timer.TIMER_PROCESS_PHYSICS
	slide_timer.autostart = false
	slide_timer.one_shot = true
	
	add_child(slide_timer)
	slide_timer.timeout.connect(on_slider_timeout)


func on_slider_timeout():
	detect_crouch()
	
	if FSM.actor.ceil_shape_detector.is_colliding():
		state_finished.emit("Crouch", {})
	else:
		animation_player.play_backwards("crouch")
		state_finished.emit("Walk", {})
	
