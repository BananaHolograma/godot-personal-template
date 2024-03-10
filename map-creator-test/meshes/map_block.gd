@tool
class_name MapBlock extends Node3D


func _enter_tree():
	add_to_group("mapblock")
	name = "MapBlock%s" % get_tree().get_nodes_in_group("mapblock").size()


func update_faces(neighbours: Dictionary):

	if neighbours.is_empty():
		return
	## I need to access here again the faces as can be updated on editor and not being ready on the scene tree yet.
	var vector_to_wall := {
		Vector2.UP: $NorthWall,
		Vector2.DOWN: $SouthWall,
		Vector2.LEFT: $WestWall,
		Vector2.RIGHT: $EastWall
	}

	for neighbour_direction in neighbours.keys():
		if neighbours[neighbour_direction]:
			var mesh = vector_to_wall[neighbour_direction]
			
			if mesh:
				mesh.hide();


func hide_floor():
	var floor = $Floor
	if floor:
		floor.hide()
	
	
func hide_ceil():
	var ceil = $Ceil
	if ceil:
		ceil.hide()


func visible_meshes():
	return get_children().filter(func(child): return child is MeshInstance3D and child.visible)
