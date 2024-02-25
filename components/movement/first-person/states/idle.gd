class_name IdleFirstPerson extends Motion


func _enter():
	FSM.actor.velocity = Vector3.ZERO


func physics_update(delta: float):
	super.physics_update(delta)
	
	if not transformed_input.input_direction.is_zero_approx():
		state_finished.emit("Walk", {})
		
	FSM.actor.velocity = lerp(FSM.actor.velocity, Vector3.ZERO, delta * friction)
	FSM.actor.move_and_slide()

	detect_jump()
	detect_crouch()
