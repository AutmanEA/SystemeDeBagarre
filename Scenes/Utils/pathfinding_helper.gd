class_name PathfindingHelper
extends RefCounted

const HEX_DIRECTIONS = [
	Vector2(1, 0), Vector2(1, -1), Vector2(0, -1), 
	Vector2(-1, 0), Vector2(-1, 1), Vector2(0, 1)
]

#function axial_subtract(a, b):
	#return Hex(a.q - b.q, a.r - b.r)
#
#function axial_distance(a, b):
	#var vec = axial_subtract(a, b)
	#return (abs(vec.q)
		  #+ abs(vec.q + vec.r)
		  #+ abs(vec.r)) / 2

static func get_tile_distance(a, b) -> float:
	return (abs(a) + abs(a + b) + abs(b)) / 2.0

static func is_tile_visible(grid: Dictionary, start_coord: Vector2, target_coord: Vector2) -> bool:
	
	if (not grid.has(start_coord)) or (not grid.has(target_coord)):
		return false
	
	var start = grid[start_coord]
	var target = grid[target_coord]
	
	var vec = Vector2(start.q - target.q, start.r - target.r) #REFACTO?
	var distance = get_tile_distance(vec.x, vec.y)

	var start_nudge = Vector2(start.q + 1e-6, start.r + 1e-6)
	var start_nudge2 = Vector2(start.q - 1e-6, start.r - 1e-6)
	var target_nudge = Vector2(target.q + 1e-6, target.r + 1e-6)
	var target_nudge2 = Vector2(target.q - 1e-6, target.r - 1e-6)

	for i in range(distance):
		var vec_lerp = Vector2(lerpf(start_nudge.x, target_nudge.x, 1.0/distance * i), lerpf(start_nudge.y, target_nudge.y, 1.0/distance * i))
		var vec_lerp2 = Vector2(lerpf(start_nudge2.x, target_nudge2.x, 1.0/distance * i), lerpf(start_nudge2.y, target_nudge2.y, 1.0/distance * i))
		if (not (grid.has(vec_lerp.round()) and grid[vec_lerp.round()].is_walkable)) and (not (grid.has(vec_lerp2.round()) and grid[vec_lerp2.round()].is_walkable)):
			return false
	return true


static func get_field_of_view(grid: Dictionary, start_coord: Vector2, range_min: int, range_max: int) -> Array:
	var fov = []
	
	if not grid.has(start_coord):
		return fov
		
	if range_min == 0:
		fov.append(start_coord)
	
	for cell in grid:
		if cell != start_coord and grid[cell].is_walkable and is_tile_visible(grid, start_coord, cell):
			var distance = get_tile_distance(start_coord.x - cell.x, start_coord.y - cell.y)
			if distance >= range_min and distance <= range_max:
				fov.append(cell)

	return fov


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
