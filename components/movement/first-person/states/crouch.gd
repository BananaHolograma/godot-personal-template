class_name CrouchFirstPerson extends Motion

@export var speed := 2.0


func _enter() -> void:
	if previous_states.is_empty() or not previous_states.back().name in ["Crawl", "Slide"]:
		animation_player.play("crouch")


func _exit():
	animation_player.play_backwards("crouch")


func physics_update(delta: float):
	super.physics_update(delta)
	
	if not Input.is_action_pressed("crouch") and not FSM.actor.ceil_shape_detector.is_colliding():
		if FSM.actor.velocity.is_zero_approx():
			state_finished.emit("Idle", {})
		else:
			state_finished.emit("Walk", {})
	
	
	move(speed)
	
	FSM.actor.move_and_slide()
