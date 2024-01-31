class_name SaveGame extends Resource

static var default_path := OS.get_user_data_dir()

@export var filename: String
@export var version_control: String = ProjectSettings.get_setting("application/config/version")
@export var engine_version: String = "Godot %s" % Engine.get_version_info().string
@export var last_datetime := ""
@export var game_settings: GameSettings

	
func write_savegame(_filename: String) -> void:
	filename = _filename.get_basename()
	update_last_datetime()
	ResourceSaver.save(self, SaveGame.get_save_path(filename))


func update_last_datetime():
	## Example { "year": 2024, "month": 1, "day": 25, "weekday": 4, "hour": 13, "minute": 34, "second": 18, "dst": false }
	var datetime = Time.get_datetime_dict_from_system()
	last_datetime = "%s/%s/%s %s:%s " % [str(datetime.day).pad_zeros(2), str(datetime.month).pad_zeros(2), datetime.year, str(datetime.hour).pad_zeros(2), str(datetime.minute).pad_zeros(2)]
	

func delete():
	if SaveGame.save_exists(filename):
		var error = DirAccess.remove_absolute(SaveGame.get_save_path(filename))
		
		if error == OK:
			GameEvents.deleted_saved_game.emit(filename)


static func save_exists(_filename: String) -> bool:
	return ResourceLoader.exists(get_save_path(_filename))
	
	
static func load_savegame(_filename: String) -> SaveGame:
	if SaveGame.save_exists(_filename):
		return ResourceLoader.load(get_save_path(_filename), "", ResourceLoader.CACHE_MODE_IGNORE) as SaveGame
	return null


static func get_save_path(_filename: String) -> String:
	return "%s/%s.%s" % [default_path, _filename.get_basename(), SaveGame.get_save_extension()]


static func get_save_extension() -> String:
	return "tres" if OS.is_debug_build() else "res"


static func read_user_saved_games() -> Dictionary:
	var saved_games := {}
	var dir = DirAccess.open(SaveGame.default_path)

	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		
		while file_name != "":
			if not dir.current_is_dir() and file_name.get_extension() in [SaveGame.get_save_extension()]:
				var saved_game = SaveGame.load_savegame(file_name.get_basename())
				
				if saved_game: 
					saved_games[saved_game.filename] = saved_game
		
			file_name = dir.get_next()
					
		dir.list_dir_end()
		
	return saved_games
