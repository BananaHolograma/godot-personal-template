@tool
extends EditorPlugin


func _enter_tree():
	add_custom_type("HealthComponent", "Node", preload("res://addons/health_component/health_component.gd"), preload("res://addons/health_component/suit_hearts.svg"))


func _exit_tree():
	remove_custom_type("HealthComponent")
	
	
