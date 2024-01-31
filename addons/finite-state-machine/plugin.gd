@tool
extends EditorPlugin

func _enter_tree():
	add_custom_type("FiniteStateMachine", "Node", preload("res://addons/finite-state-machine/finite-state-machine.gd"), preload("res://addons/finite-state-machine/icons/icon.png"))
	add_custom_type("State", "Node", preload("res://addons/finite-state-machine/state.gd"), preload("res://addons/finite-state-machine/icons/state_icon.png"))

func _exit_tree():
	remove_custom_type("FiniteStateMachine")
	remove_custom_type("State")
	
