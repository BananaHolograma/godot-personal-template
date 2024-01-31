class_name Hitbox3D extends Area3D


func _init() -> void:
	collision_mask = 0
	collision_layer = 16 ## Hitboxes layer
	monitoring = false
