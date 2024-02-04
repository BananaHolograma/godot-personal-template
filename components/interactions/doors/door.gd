class_name Door extends Node3D

signal opened
signal closed
signal unlocked

@export_group("Interaction parameters")
@export var is_open := false:
	set(value):
		if value != is_open:
			if value:
				opened.emit()
			else:
				closed.emit()
		is_open = value
		
@export var locked := false:
	set(value):
		if value != locked:
			if value:
				unlocked.emit()
			
		locked = value
@export var key: PackedScene
@export var delay_before_close := 0.0


func open():
	pass


func close():
	pass


func unlock():
	pass


func is_locked():
	return locked
