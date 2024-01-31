class_name FadeOverlay extends ColorRect

signal on_complete_fade_in
signal on_complete_fade_out

@export var fade_in_duration := 2.0
@export var fade_out_duration := 1.0
@export var auto_fade_in := true 
@export var minimum_opacity := 1.0


func _ready():
	modulate.a = minimum_opacity
	
	if auto_fade_in:
		fade_in()


func fade_in():
	var tween = create_tween()
	tween.tween_property(self, "modulate", Color(modulate, 0.0), fade_in_duration).set_trans(Tween.TRANS_CUBIC)\
		.finished.connect(_on_complete_fade_in)


func fade_out():
	var tween = create_tween()
	tween.tween_property(self, "modulate", Color(modulate, minimum_opacity), fade_out_duration).set_trans(Tween.TRANS_CUBIC)\
		.finished.connect(_on_complete_fade_out)


func _on_complete_fade_out():
	on_complete_fade_out.emit()
	
func _on_complete_fade_in():
	on_complete_fade_in.emit()
