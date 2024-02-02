class_name GameSettings extends Resource


## Remember to set the volume sliders with max value of 1 and step of 0.001 to apply the volume changes properly.
@export var audio := {
	"music": 1.0,
	"sfx": 1.0,
	"ui": 1.0,
	"ambient": 1.0
}

@export_range(1.0, 20.0, 0.1) var mouse_sensitivity := 3.0
@export var display_mode := DisplayServer.WINDOW_MODE_WINDOWED
@export var vsync := DisplayServer.VSYNC_DISABLED
@export var antialiasing :=  Viewport.MSAA_DISABLED

## https://docs.godotengine.org/en/stable/tutorials/i18n/locales.html
@export var language: String = "en"
