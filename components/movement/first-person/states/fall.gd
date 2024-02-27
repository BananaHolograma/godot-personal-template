class_name Fall extends Motion


func physics_update(delta: float):
	super.physics_update(delta)
	
	if not was_grounded and is_grounded:
		if transformed_input.input_direction.is_zero_approx():
			state_finished.emit("Idle", {})
		else:
			state_finished.emit("Walk", {})

	move(2.0)
	
	FSM.actor.move_and_slide()
	
