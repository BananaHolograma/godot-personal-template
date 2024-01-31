class_name Hurtbox2D extends Area2D

signal hitbox_detected(hitbox: Hitbox2D)


func _init() -> void:
	monitorable = false
	collision_mask = 16 ## Hitboxes layer
	

func _ready():
	area_entered.connect(on_area_entered)


func on_area_entered(hitbox: Hitbox2D) -> void:
	hitbox_detected.emit(hitbox)
