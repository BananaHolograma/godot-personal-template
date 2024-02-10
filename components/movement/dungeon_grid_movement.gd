class_name DungeonGridMovement extends Node

@export var cell_travel_size := 2
@export var movement_animation_time := 0.3

@onready var target: Node3D = get_parent() as Player

var tween_movement: Tween

func move(direction: Vector2):
	if target:
		if tween_movement and tween_movement.is_running():
			return
	
		match(direction):
			Vector2.UP:
				tween_movement = create_tween()
				tween_movement.tween_property(target, "transform", target.transform.translated_local(Vector3.FORWARD * cell_travel_size), movement_animation_time)\
				.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
			Vector2.DOWN:
				tween_movement = create_tween()
				tween_movement.tween_property(target, "transform", target.transform.translated_local(Vector3.BACK * cell_travel_size), movement_animation_time)\
					.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
			Vector2.RIGHT:
				tween_movement = create_tween()
				tween_movement.tween_property(target, "transform", target.transform.translated_local(Vector3.RIGHT * cell_travel_size), movement_animation_time)\
					.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
			Vector2.LEFT:
				tween_movement = create_tween()
				tween_movement.tween_property(target, "transform", target.transform.translated_local(Vector3.LEFT * cell_travel_size), movement_animation_time)\
					.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)


func rotate(direction: Vector2):
	if direction in [Vector2.LEFT, Vector2.RIGHT]:
		if tween_movement and tween_movement.is_running():
			return
	
		tween_movement = create_tween()
		tween_movement.tween_property(target, "transform:basis", target.transform.basis.rotated(Vector3.UP, -sign(direction.x) * PI / 2), movement_animation_time)\
			.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	