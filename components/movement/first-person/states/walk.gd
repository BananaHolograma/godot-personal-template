class_name WalkFirstPerson extends Motion

@export var speed := 3.5
@export var catching_breath_recovery_time := 3.0

var catching_breath_timer : Timer


func _ready():
	_create_sprint_recovery_timer()


func _enter():
	catching_breath()
	FSM.actor.velocity.y = 0


func physics_update(delta: float):
	super.physics_update(delta)
	
	move(speed)
	
	if transformed_input.world_coordinate_space_direction.is_zero_approx() or FSM.actor.velocity.is_zero_approx():
		state_finished.emit("Idle", {})
		return
		
	if Input.is_action_pressed("run") and catching_breath_timer.is_stopped() and FSM.actor.RUN:
		state_finished.emit("Run", {})
		return
	
	stair_step_up()
	
	FSM.actor.move_and_slide()
	
	stair_step_down()
	
	detect_jump()
	detect_crouch()


func catching_breath():
	if params.has("catching_breath") and params["catching_breath"] and catching_breath_timer.is_stopped():
		catching_breath_timer.start()
		
		
func _create_sprint_recovery_timer() -> void:
	catching_breath_timer = Timer.new()
	catching_breath_timer.name = "SprintRecoveryTimer"
	catching_breath_timer.wait_time = catching_breath_recovery_time
	catching_breath_timer.process_callback = Timer.TIMER_PROCESS_PHYSICS
	catching_breath_timer.autostart = false
	catching_breath_timer.one_shot = true
	
	add_child(catching_breath_timer)
