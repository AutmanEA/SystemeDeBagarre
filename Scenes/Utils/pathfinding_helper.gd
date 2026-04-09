class_name PathfindingHelper
extends RefCounted

const HEX_DIRECTIONS = [
	Vector2(1, 0), Vector2(1, -1), Vector2(0, -1), 
	Vector2(-1, 0), Vector2(-1, 1), Vector2(0, 1)
]

static func get_reachable_tiles(grid: Dictionary, pawns: Dictionary, start_coord: Vector2, movement: int) -> Dictionary:
	var came_from = {}

	if not grid.has(start_coord): 
		return came_from
		
	came_from[start_coord] = null
	var fringes = [[grid[start_coord]]]

	for k in range(1, movement + 1):
		fringes.append([])
		for hex in fringes[k - 1]:
			var hex_coord = Vector2(hex.q, hex.r)

			for dir in HEX_DIRECTIONS:
				var neighbor_coord = hex_coord + dir
				if grid.has(neighbor_coord):
					var neighbor = grid[neighbor_coord]

					if not came_from.has(neighbor_coord) and neighbor.is_walkable and not pawns.has(neighbor_coord):
						came_from[neighbor_coord] = hex_coord
						fringes[k].append(neighbor)

	return came_from


static func reconstruct_path(target_coord: Vector2, current_reachable_tiles: Dictionary) -> Array[Vector2]:
	var path: Array[Vector2] = []
	var current = target_coord
	
	while current != null:
		path.append(current)
		current = current_reachable_tiles[current] 

	path.reverse()
	return path
