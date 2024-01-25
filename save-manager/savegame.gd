class_name SaveGame extends Resource

static var default_path := OS.get_user_data_dir()

@export var version_control := "1.0.0"

func write_savegame(filename: String) -> void:
	ResourceSaver.save(self, SaveGame.get_save_path(filename))


static func save_exists(filename: String) -> bool:
	return ResourceLoader.exists(SaveGame.get_save_path(filename))
	
	
static func load_savegame(filename: String) -> Resource:
	if save_exists(filename):
		return ResourceLoader.load(SaveGame.get_save_path(filename), "", ResourceLoader.CACHE_MODE_IGNORE)
	return null


static func get_save_path(filename: String) -> String:
	return "%s/%s.%s" % [default_path, filename, SaveGame.get_save_extension()]


static func get_save_extension() -> String:
	return "tres" if OS.is_debug_build() else "res"


static func read_user_saved_games():
	var dir = DirAccess.open(SaveGame.default_path)

	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if not dir.current_is_dir() and file_name.get_extension() in [SaveGame.get_save_extension()]:
				var saved_game = load_savegame(file_name.get_basename())
				
				## TODO -
				if saved_game:
					pass
		
			file_name = dir.get_next()
					
		dir.list_dir_end()
