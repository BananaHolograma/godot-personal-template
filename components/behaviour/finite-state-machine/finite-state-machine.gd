##
# Created by https://github.com/bananaholograma organization with LICENSE MIT
# There are no restrictions on modifying, sharing, or using this component commercially
# We greatly appreciate your support in the form of stars, as they motivate us to continue our journey of enhancing the Godot community
# ***************************************************************************************
# A finite state machine designed to cover 95% of use cases, providing essential functionality and a basic state node that can be extended.

# There is nothing wrong using the same process on the CharacterBody2D to handle all the movement but when the things start to grow and the player can perform a wide number of moves it is better to start thinking about a modular way to build this movement. 
# In this case, a state machine is a design pattern widely employed in the video game industry to manage this complexity
##
@icon("res://components/behaviour/finite-state-machine/icons/icon.png")
class_name FiniteStateMachine extends Node

signal state_changed(from_state: State, state: State)
signal stack_pushed(new_state: State, stack:Array[State])
signal stack_flushed(flushed_states: Array[State])

@export var actor: Node
@export var current_state: State = null
@export var stack_capacity: int = 3
@export var flush_stack_when_reach_capacity: bool = false
@export var enable_stack: bool = true

var states: Dictionary = {}
var states_stack: Array[State] = []
var next_state: State
var locked: bool = false
		
func _ready():
	_initialize_states_nodes()
	for initialized_state: State in states.values():
		initialized_state.state_finished.connect(on_finished_state)
		initialized_state.FSM = self
		initialized_state.ready()
	
	if current_state is State:
		change_state(current_state, {},  true)
	
	unlock_state_machine()
	
	stack_pushed.connect(on_stack_pushed)


func _unhandled_input(event):
	current_state.handle_input(event)


func _physics_process(delta):
	current_state.physics_update(delta)


func _process(delta):
	current_state.update(delta)
		

func change_state(new_state: State,  params: Dictionary = {}, force: bool = false):
	if not force and current_state_is(new_state):
		return
	
	if current_state is State and next_state is State:
		exit_state(current_state, next_state)
	
	push_state_to_stack(current_state)
	state_changed.emit(current_state, new_state)
	
	current_state = new_state
	current_state.params = params
	
	enter_state(new_state)
	next_state = null

	
func change_state_by_name(_name: String, params: Dictionary = {}, force: bool = false):
	var new_state = get_state(_name)
	
	if new_state:
		return change_state(new_state, params, force)
		
	push_error("FiniteStateMachinePlugin: The state {name} does not exists on this FiniteStateMachine".format({"name": _name}))


func enter_state(state: State):
	state._enter()
	state.state_entered.emit()
	

func exit_state(state: State, _next_state: State):
	state._exit(_next_state)


func push_state_to_stack(state: State) -> void:
	if enable_stack and stack_capacity > 0:
		if states_stack.size() >= stack_capacity:
			if flush_stack_when_reach_capacity:
				stack_flushed.emit(states_stack)
				states_stack.clear()
			else:
				states_stack.pop_front()
			
		states_stack.append(state)
		stack_pushed.emit(state, states_stack)
			

func get_state(_name: String):
	if has_state(_name):
		return states[_name]
	
	return null


func has_state(_name: String) -> bool:
	return states.has(_name)
	

func current_state_is(state: State) -> bool:
	if state:
		return state.name.to_lower() == current_state.name.to_lower()
		
	return false


func current_state_name_is(_name: String) -> bool:
	return current_state_is(get_state(_name))


func lock_state_machine():
	set_process(false)
	set_physics_process(false)
	set_process_input(false)
	set_process_unhandled_input(false)

	
func unlock_state_machine():
	set_process(true)
	set_physics_process(true)
	set_process_input(true)
	set_process_unhandled_input(true)

		
func _initialize_states_nodes(node: Node = null):
	var childrens = node.get_children(true) if node else get_children(true)
	
	for child in childrens:
		if child is State:
			_add_state_to_dictionary(child)
		else:
			_initialize_states_nodes(child)


func _add_state_to_dictionary(state: State):
	if state.is_inside_tree():
		states[state.name] = get_node(state.get_path())


func on_finished_state(_next_state, params):	
	if typeof(_next_state) == TYPE_STRING:
		next_state =  get_state(_next_state)
		change_state_by_name(_next_state,  params, false)
		
	if _next_state is State:
		next_state = _next_state
		change_state(_next_state, params, false)


func on_stack_pushed(_new_state: State, stack:Array[State]):
	for state in states.values():
		if state is State:	
			state.previous_states = stack
