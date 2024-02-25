class_name GameSettings extends Resource


## Remember to set the volume sliders with max value of 1 and step of 0.001 to apply the volume changes properly.
@export var AUDIO_VOLUMES := {
	"music": 1.0,
	"sfx": 1.0,
	"ui": 1.0,
	"ambient": 1.0
}

@export_range(1.0, 20.0, 0.1) var MOUSE_SENSITIVITY := 3.0
@export var DISPLAY_MODE := DisplayServer.WINDOW_MODE_WINDOWED
@export var VSYNC := DisplayServer.VSYNC_DISABLED
@export var ANTIALIASING :=  Viewport.MSAA_DISABLED
@export var RESOLUTIONS := [
	{"value":  Vector2(640, 360), "enabled": true},
	{"value":  Vector2(960, 540), "enabled": true},
	{"value":  Vector2(1280, 720), "enabled": true},
	{"value":  Vector2(1440, 810), "enabled": true},
	{"value":  Vector2(1920, 1080), "enabled": true},
 ]

## https://docs.godotengine.org/en/stable/tutorials/i18n/locales.html
@export var language: String = "en"


func set_volume(bus: String, value: float):
	if AUDIO_VOLUMES.has(bus):
		AUDIO_VOLUMES[bus] = value
