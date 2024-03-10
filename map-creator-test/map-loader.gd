@tool
class_name MapLoader extends Node3D


@export_file("*.tscn") var map_file_path: String = ""
@export var generate := false:
	set(value):
		generate = false
		generate_map()
		
@export var clear_map := false:
	set(value):
		clear_map = false
		clear()

	
func generate_map():
	var cached_scenes := {}
	var editor_tree := get_tree().get_edited_scene_root()
		
	if _map_file_is_valid(map_file_path):
		clear()
		var map: PackedScene = load(map_file_path) as PackedScene
		var map_scene = map.instantiate()
		
		if map_scene.get_child_count() == 0:
			push_error("The map scene loaded does not have a tilemap node")
			return
			
		## TODO - LOAD MULTIPLE TILEMAPS INSTEAD ONLY ONE
		var tilemap: TileMap = map_scene.get_child(0) as TileMap
		
		var cells = tilemap.get_used_cells(0)
		
		for cell in cells:
			var data = tilemap.get_cell_tile_data(0, cell)
			
			if data is TileData:
				var mesh_scene = obtain_scene_from_custom_tile_data(data, cached_scenes)
				
				if mesh_scene is PackedScene:
					var map_block = mesh_scene.instantiate() as MapBlock
					map_block.translate(Vector3(cell.x * 2, 0, cell.y * 2))
					add_child(map_block)
					map_block.update_faces(get_neighbours(cells, cell))
					
					if Engine.is_editor_hint():
						map_block.set_owner(editor_tree)
	else:
		push_error("The map file path is empty or the file does not exists.")


func obtain_scene_from_custom_tile_data(data: TileData, cached_scenes: Dictionary) -> PackedScene:
	var scene_path = data.get_custom_data_by_layer_id(0)
	var mesh_scene: PackedScene
	
	if not Engine.is_editor_hint() and cached_scenes.has(scene_path):
		mesh_scene = cached_scenes[scene_path]
	else:
		if _map_file_is_valid(scene_path):
			cached_scenes[scene_path] = ResourceLoader.load(scene_path) as PackedScene
			mesh_scene = cached_scenes[scene_path]
	
	return mesh_scene


func clear():
	for child in get_children():
		if not child is MapLoader:
			child.queue_free()


func get_neighbours(cells: Array[Vector2i], cell: Vector2i) -> Dictionary:
	return {
		Vector2.UP: has_neighbour(cells, cell, Vector2i.UP),
		Vector2.DOWN: has_neighbour(cells, cell, Vector2i.DOWN),
		Vector2.LEFT: has_neighbour(cells, cell, Vector2i.LEFT),
		Vector2.RIGHT: has_neighbour(cells, cell, Vector2i.RIGHT),
	}


func has_neighbour(cells: Array[Vector2i], cell: Vector2i, direction: Vector2i) -> bool:
	return cells.has(cell + direction)
	
	
func _map_file_is_valid(map_file: String) -> bool:
	return map_file and not map_file.is_empty() and ResourceLoader.exists(map_file)


