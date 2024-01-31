class_name Hitbox2D extends Area2D


func _init() -> void:
	collision_mask = 0
	collision_layer = 16 ## Hitboxes layer
	monitoring = false
