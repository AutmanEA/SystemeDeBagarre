class_name PathfindingHelper
extends RefCounted






func reconstruct_path(target_coord: Vector2, current_reachable_tiles: Dictionary) -> Array[Vector2]:
	var path: Array[Vector2] = []
	var current = target_coord
	
	while current != null:
		path.append(current)
		current = current_reachable_tiles[current] 

	path.reverse()
	return path
