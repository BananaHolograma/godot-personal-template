class_name RotatorComponent extends Node3D

@onready var target: Node3D = get_parent()
@export var mouse_sensitivity := 3.0


func _input(event: InputEvent):
	if Input.is_action_pressed("rotate_object") and event is InputEventMouseMotion:
		target.rotate_x(event.relative.y / 1000 * mouse_sensitivity)
		target.rotate_y(event.relative.x / 1000 * mouse_sensitivity)
		
