extends Node

signal removed_saved_game(filename)

@export var list_of_saved_games := {}
@export var current_saved_game: SaveGame


func remove(filename: String) -> void:
	removed_saved_game.emit(filename)
	list_of_saved_games.erase(filename)
