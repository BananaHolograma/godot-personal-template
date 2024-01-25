class_name SaveGame extends Resource

static var default_path := OS.get_user_data_dir()

## The version of the game that was saved, important when it comes to load and update the game if it's needed
@export var version_control := "1.0.0"
@export var last_datetime := ""

## This is the place where all the resources and variables can be added to be saved & loaded

func write_savegame(filename: String) -> void:
	update_last_datetime()
	ResourceSaver.save(self, SaveGame.get_save_path(filename))


func update_last_datetime():
	## Example { "year": 2024, "month": 1, "day": 25, "weekday": 4, "hour": 13, "minute": 34, "second": 18, "dst": false }
	var datetime = Time.get_datetime_dict_from_system()
	last_datetime = "%s/%s/%s %s:%s " % [str(datetime.day).pad_zeros(2), str(datetime.month).pad_zeros(2), datetime.year, str(datetime.hour).pad_zeros(2), str(datetime.minute).pad_zeros(2)]
	
	
static func save_exists(filename: String) -> bool:
	return ResourceLoader.exists(SaveGame.get_save_path(filename))
	
	
static func load_savegame(filename: String) -> Resource:
	if SaveGame.save_exists(filename):
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
				var saved_game = SaveGame.load_savegame(file_name.get_basename())
				
				## TODO -
				if saved_game:
					pass
		
			file_name = dir.get_next()
					
		dir.list_dir_end()
