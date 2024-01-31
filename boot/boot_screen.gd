extends Control

@export var next_scene: PackedScene

@onready var audio_stream_player_2d: AudioStreamPlayer2D = $AudioStreamPlayer2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer


func _input(event):
	if Input.is_action_just_pressed("ui_accept"):
		animation_player.stop()
		get_tree().change_scene_to_packed(next_scene)
	
	
func _ready():
	animation_player.play("fade_in")
	animation_player.animation_finished.connect(on_animation_finished)	


func on_animation_finished(name: String):
	if next_scene is PackedScene and name == "fade_in":
		get_tree().change_scene_to_packed(next_scene)
