class_name PathfindingHelper
extends RefCounted

var grid: Dictionary
var pawns: Dictionary

func _init(_grid: Dictionary, _pawns: Dictionary) -> void:
	grid = _grid
	pawns = _pawns

const HEX_DIRECTIONS = [
	Vector2(1, 0), Vector2(1, -1), Vector2(0, -1), 
	Vector2(-1, 0), Vector2(-1, 1), Vector2(0, 1)
]

func get_tile_distance(a, b) -> float:
	return (abs(a) + abs(a + b) + abs(b)) / 2.0

func is_path_valid(distance: float, start_coord: Vector2, target_coord: Vector2, epsilon: Vector2) -> bool:
	if distance == 0:
		return true
	
	var start = start_coord + epsilon
	var target = target_coord + epsilon
	
	var path = true
	
	for i in range(1, distance):
		var lerp_t = float(i) / distance
		
		if path:
			var step_coord = start.lerp(target, lerp_t).round()
			if not grid.has(step_coord) or not grid[step_coord].is_walkable or pawns.has(step_coord):
				path = false
	
	return path

func is_tile_visible(start_coord: Vector2, target_coord: Vector2) -> bool:
	
	if (not grid.has(start_coord)) or (not grid.has(target_coord)):
		return false
	
	var distance = get_tile_distance(start_coord.x - target_coord.x, start_coord.y - target_coord.y)
	if distance == 0:
		return true
	
	var p_path = is_path_valid(distance, start_coord, target_coord, Vector2(1e-6, 1e-6))
	var n_path = is_path_valid(distance, start_coord, target_coord, Vector2(-1e-6, -1e-6))
	
	if not p_path and not n_path:
		return false

	return true


func get_field_of_view(start_coord: Vector2, range_min: int, range_max: int) -> Array:
	var fov = []
	
	if not grid.has(start_coord):
		return fov
		
	if range_min == 0:
		fov.append(start_coord)
	
	for cell in grid:
		if cell != start_coord and grid[cell].is_walkable and is_tile_visible(start_coord, cell):
			var distance = get_tile_distance(start_coord.x - cell.x, start_coord.y - cell.y)
			if distance >= range_min and distance <= range_max:
				fov.append(cell)

	return fov


func get_reachable_tiles(start_coord: Vector2, movement: int) -> Dictionary:
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


func reconstruct_path(target_coord: Vector2, current_reachable_tiles: Dictionary) -> Array[Vector2]:
	var path: Array[Vector2] = []
	var current = target_coord
	
	while current != null:
		path.append(current)
		current = current_reachable_tiles[current] 

	path.reverse()
	return path
