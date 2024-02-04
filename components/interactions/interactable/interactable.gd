class_name Interactable extends Area3D

signal focused(interactor: Interactor)
signal unfocused(interactor: Interactor)
signal interacted(interactor: Interactor)
signal cancel_interact(interactor: Interactor)

@export_group("Interaction Parameters")
@export var parameters: InteractableParameters
@onready var target = get_parent()
@export_group("Pointers")
@export var focus_pointer: CompressedTexture2D
@export var interact_pointer: CompressedTexture2D

var actor: Interactor

func _ready():
	collision_layer = 2 # Interactable layer
	collision_mask = 0
	priority = 3
	monitoring = false
	monitorable = true
	
	interacted.connect(on_interacted)
	cancel_interact.connect(on_cancel_interact)
	focused.connect(on_focused)
	unfocused.connect(on_unfocused)


func is_scannable() -> bool:
	return parameters.scannable


func is_pickable() -> bool:
	return parameters.pickable


func is_usable() -> bool:
	return parameters.usable


func can_be_saved_on_inventory() -> bool:
	return parameters.can_be_saved
	
	
func on_interacted(interactor: Interactor) -> void:
	actor = interactor
	
	if parameters.lock_player:
		GameEvents.lock_player.emit()
	GameEvents.interacted.emit(self)


func on_cancel_interact(_interactor: Interactor) -> void:
	actor = null
	
	if parameters.lock_player:
		GameEvents.unlock_player.emit()
	GameEvents.cancel_interact.emit(self)
	
	
func on_focused(_interactor: Interactor) -> void:
	GameEvents.focused.emit(self)


func on_unfocused(_interactor: Interactor) -> void:
	GameEvents.unfocused.emit(self)
