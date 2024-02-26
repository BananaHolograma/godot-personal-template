class_name CrawlFirstPerson extends Motion

@export var speed := 1.0


func _enter() -> void:
	animation_player.play("crawl")


func _exit(_next_state: State):
	animation_player.play_backwards("crawl")


func physics_update(delta: float):
	super.physics_update(delta)
	
	if not Input.is_action_pressed("crawl") and not FSM.actor.ceil_shape_detector.is_colliding():
		state_finished.emit("Crouch", {})
	
	move(speed)
	
	FSM.actor.move_and_slide()
