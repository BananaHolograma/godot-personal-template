class_name Hands extends Node3D

signal picked(picked_object: Interactable)
signal dropped(dropped_object: Interactable)
signal throwed(throwed_object: Interactable)
signal picked_heavy_lift(picked_object: Interactable, mass_limit: float)

enum HANDS {
	RIGHT,
	LEFT
}

@export var camera: Camera3D
## The maximum weight this hands can grab
@export var maximum_lift_mass := 10.0
@export var dominant_hand := HANDS.RIGHT
@export var can_use_both_hands := true

@onready var right_hand: Marker3D = $RightHand
@onready var left_hand: Marker3D = $LeftHand
@onready var picked_objects := {
	HANDS.RIGHT: {"object": null, "hand": right_hand, "priority": 0},
	HANDS.LEFT:  {"object": null, "hand": left_hand, "priority": 0}
}


func _unhandled_input(_event: InputEvent):
	if not _hand_is_free(HANDS.RIGHT):
		if InputMap.has_action("interact") and Input.is_action_just_pressed("interact"):
			drop(HANDS.RIGHT)
		
	if InputMap.has_action("throw") and Input.is_action_just_pressed("throw"):
		throw(HANDS.RIGHT)


func _ready():
	GameEvents.interacted.connect(on_interact)
	dropped.connect(on_object_dropped)
	throwed.connect(on_object_throwed)
	
	set_physics_process(false)


func _physics_process(_delta:float):
	if picked_objects[HANDS.RIGHT]["object"]:
		var interactable = picked_objects[HANDS.RIGHT]["object"] as Interactable
		interactable.target.linear_velocity = (right_hand.global_position - interactable.target.global_position) * interactable.parameters.pull_power
	
	if picked_objects[HANDS.LEFT]["object"]:
		var interactable = picked_objects[HANDS.LEFT]["object"] as Interactable
		interactable.target.linear_velocity = (left_hand.global_position - interactable.target.global_position) * interactable.parameters.pull_power
	

func pick(interactable: Interactable):
	if can_use_both_hands:
		if _hand_is_free(dominant_hand):
			picked_objects[dominant_hand]["object"] = interactable
			picked_objects[dominant_hand]["priority"] = 2
			_move_object_to_hand(interactable, picked_objects[dominant_hand]["hand"])
		else:
			var second_hand = HANDS.LEFT if dominant_hand == HANDS.RIGHT else HANDS.RIGHT
			if _hand_is_free(second_hand):
				picked_objects[second_hand]["object"] = interactable
				picked_objects[dominant_hand]["priority"] = 1
				_move_object_to_hand(interactable, picked_objects[second_hand]["hand"])
	else:
		if _hand_is_free(dominant_hand):
			picked_objects[dominant_hand]["object"] = interactable
			picked_objects[dominant_hand]["priority"] = 2
			_move_object_to_hand(interactable, picked_objects[dominant_hand]["hand"])
		

func throw(hand: HANDS):
	if not _hand_is_free(hand):
		var interactable = picked_objects[hand]["object"] as Interactable
		var direction = Vector3.FORWARD.z * camera.global_transform.basis.z.normalized() #global_position.direction_to(interactable.target.global_position)

		interactable.target.apply_impulse(direction * interactable.parameters.throw_power)
		interactable.actor.cancel_interact(interactable)
		
		picked_objects[hand]["object"] = null
		throwed.emit(interactable)			
	
	
func _move_object_to_hand(picked_object: Interactable, hand: Marker3D):
	set_physics_process(true)
	
	var tween = create_tween()
	tween.tween_property(picked_object.target, "global_position", hand.global_position, 0.4)\
		.from(picked_object.target.global_position).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	
	picked_object.deactivate()
	picked.emit(picked_object)
	

func drop(hand: HANDS):
	if not _hand_is_free(hand):
		var interactable = picked_objects[hand]["object"] as Interactable

		interactable.actor.cancel_interact(interactable)
		dropped.emit(interactable)
		picked_objects[hand]["object"] = null


func _hand_is_free(hand: HANDS):
	return picked_objects[hand]["object"] == null


func _update_hands_physics():
	if _hand_is_free(HANDS.RIGHT) and _hand_is_free(HANDS.LEFT):
		set_physics_process(false)


func on_interact(interactable: Interactable):
	if interactable.is_pickable():
		if interactable.target.mass <= maximum_lift_mass:
			pick(interactable)
		else:
			picked_heavy_lift.emit(interactable, maximum_lift_mass)


func on_object_dropped(dropped_object: Interactable):
	dropped_object.activate()
	dropped_object.target.linear_velocity = Vector3.ZERO
	
	_update_hands_physics()


func on_object_throwed(throwed_object: Interactable):
	throwed_object.activate()
	_update_hands_physics()
