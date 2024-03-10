@tool
class_name MapBlock extends Node3D

@onready var floor_mesh: MeshInstance3D = $Floor
@onready var ceil_mesh: MeshInstance3D = $Ceil
@onready var north_wall: MeshInstance3D = $NorthWall
@onready var south_wall: MeshInstance3D = $SouthWall
@onready var east_wall: MeshInstance3D = $EastWall
@onready var west_wall: MeshInstance3D = $WestWall


func _enter_tree():
	add_to_group("mapblock")
	name = "MapBlock%s" % get_tree().get_nodes_in_group("mapblock").size()


func update_faces(neighbours: Dictionary):

	if neighbours.is_empty():
		return
	## I need to access here as the faces can be updated on editor and not ready on the scene tree
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

func visible_meshes():
	return get_children().filter(func(child): return child is MeshInstance3D and child.visible)
