class_name WalkFirstPerson extends Motion

@export var speed := 3.5


func physics_update(delta: float):
	super.physics_update(delta)
	
	move(speed)
	
	if transformed_input.world_coordinate_space_direction.is_zero_approx() or FSM.actor.velocity.is_zero_approx():
		state_finished.emit("Idle", {})
		return
	
	
	FSM.actor.move_and_slide()
