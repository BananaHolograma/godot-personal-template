class_name RunFirstPerson extends Motion

@export var speed := 5.5
## Leave it to zero to be able to run indefinitely
@export var sprint_time := 4.0

var speed_timer: Timer

func _ready():
	_create_speed_timer()


func _enter():
	if sprint_time > 0:
		speed_timer.start()


func _exit(_next_state: State):
	speed_timer.stop()


func physics_update(delta):
	super.physics_update(delta)
	
	move(speed, delta)
	
	if Input.is_action_just_released("run"):
		if FSM.actor.velocity.is_zero_approx():
			state_finished.emit("Idle", {})
		else:
			state_finished.emit("Walk", {})
			
	if Input.is_action_just_pressed("crouch") and FSM.actor.SLIDE:
		state_finished.emit("Slide", {})
		return
	
	detect_jump()
	
	FSM.actor.move_and_slide()


func _create_speed_timer() -> void:
	if speed_timer == null:
		speed_timer = Timer.new()
		speed_timer.name = "RunSpeedTimer"
		speed_timer.wait_time = sprint_time
		speed_timer.process_callback = Timer.TIMER_PROCESS_PHYSICS
		speed_timer.autostart = false
		speed_timer.one_shot = true
		
		add_child(speed_timer)
		speed_timer.timeout.connect(on_speed_timeout)
		
	
func on_speed_timeout():
	state_finished.emit("Walk", {"catching_breath": true})
