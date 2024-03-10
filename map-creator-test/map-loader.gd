@tool
class_name MapLoader extends Node3D


@export_file("*.tscn") var map_file_path: String = ""
@export var grid_size := 2
@export var generate := false:
	set(value):
		generate = false
		generate_map()
		
@export var clear_map := false:
	set(value):
		clear_map = false
		clear()

@export_group("Merge meshes")
@export var merge_meshes := true
	

func generate_map():
	var cached_scenes := {}
	var editor_tree := get_tree().get_edited_scene_root()
	var result_mesh := {
		"floor": {"mesh": ArrayMesh.new(), "material": null, "surface_tool": SurfaceTool.new() },
		"ceil": {"mesh": ArrayMesh.new(), "material": null, "surface_tool": SurfaceTool.new() },
		"walls": {"mesh": ArrayMesh.new(), "material": null, "surface_tool": SurfaceTool.new() }
	}
	var result_mesh_material:Material
	
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
		
		var map_root = Node3D.new();
		map_root.name = "MapLevelRoot"
		add_child(map_root)
		
		if Engine.is_editor_hint():
			map_root.set_owner(editor_tree)
		
		for cell in cells:
			var data = tilemap.get_cell_tile_data(0, cell)
			
			if data is TileData:
				var mesh_scene = obtain_scene_from_custom_tile_data(data, cached_scenes)
				
				if mesh_scene is PackedScene:
					var map_block = mesh_scene.instantiate() as MapBlock
					map_block.translate(Vector3(cell.x * grid_size, 0, cell.y * grid_size))
					map_root.add_child(map_block)
					map_block.update_faces(get_neighbours(cells, cell))
					
					if merge_meshes:
						for mesh_to_merge in map_block.visible_meshes():
							var mesh_key = get_key_type_from_mesh(mesh_to_merge)
							result_mesh[mesh_key]["surface_tool"].append_from(mesh_to_merge.mesh, 0, mesh_to_merge.global_transform)
							result_mesh[mesh_key]["mesh"] = result_mesh[mesh_key]["surface_tool"].commit()
				

					if Engine.is_editor_hint():
						map_block.set_owner(editor_tree)
						
		if merge_meshes:
			var floor_mesh = MeshInstance3D.new()
			var ceil_mesh = MeshInstance3D.new()
			var walls_mesh = MeshInstance3D.new()
			
			floor_mesh.name = "FloorMesh"
			ceil_mesh.name = "CeilMesh"
			walls_mesh.name = "WallsMesh"
			
			add_child(floor_mesh)
			add_child(ceil_mesh)
			add_child(walls_mesh)
			
			if Engine.is_editor_hint():
				floor_mesh.set_owner(editor_tree)
				ceil_mesh.set_owner(editor_tree)
				walls_mesh.set_owner(editor_tree)
				
			floor_mesh.mesh = result_mesh["floor"]["mesh"]
			ceil_mesh.mesh = result_mesh["ceil"]["mesh"]
			walls_mesh.mesh = result_mesh["walls"]["mesh"]
			map_root.queue_free()
	else:
		push_error("The map file path is empty or the file does not exists.")


func get_key_type_from_mesh(mesh: MeshInstance3D) -> String:
	return "walls" if mesh.name.to_lower().contains("wall") else mesh.name.to_lower()


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


