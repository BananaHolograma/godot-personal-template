class_name Orbit2DComponent extends Node2D

signal started
signal stopped

## The node that will be used as center reference for this cursor to orbit
@export var rotation_reference: Node
## The distance between the rotation reference center and the cursor starting from the center
@export var radius := 40
## This value always cannot be zero as the rotation needs at least a floating point value to start
@export var angle := PI / 4 
## The angular velocity which is used to rotate around the orbit.
@export var angular_velocity = PI / 2


var active := false:
	set(value):
		if value != active:
			if value:
				started.emit()
			else:
				stopped.emit()
				
		active = value


func _process(delta):
	if active:
		orbit(delta)


func orbit(delta: float = get_process_delta_time()):
	active = true
	angle += delta * angular_velocity
	angle = fmod(angle, 2 * PI) ## This keeps the value range between 0 and 360 degrees
	
	var offset = Vector2(cos(angle), sin(angle)) * radius
	
	position = rotation_reference.position + offset


func stop() -> void:
	active = false
