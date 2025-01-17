@icon("res://components/behaviour/finite-state-machine/icons/state_icon.png")
class_name State extends Node

signal state_entered
signal state_finished(next_state, params: Dictionary)

var FSM: FiniteStateMachine
var previous_states: Array[State] = []
var params: Dictionary = {}

func ready() -> void:
	pass
	
func _enter() -> void:
	pass
	

func _exit(_next_state: State) -> void:
	pass
	

func handle_input(_event):
	pass	


func physics_update(_delta):
	pass
	
	
func update(_delta):
	pass
	

func _on_animation_player_finished(_name: String):
	pass


func _on_animation_finished():
	pass
