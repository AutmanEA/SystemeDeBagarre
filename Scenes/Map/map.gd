class_name Map
extends Node2D

signal grid_tile_clicked(coord: Vector2)
#signal grid_tile_hovered(coord: Vector2)

const TILE_SCENE = preload("res://Scenes/Map/tile.tscn")
const HEX_DIRECTIONS = [
	Vector2(1, 0), Vector2(1, -1), Vector2(0, -1), 
	Vector2(-1, 0), Vector2(-1, 1), Vector2(0, 1)
]

# loads tiles objects
@onready var tiles: Node2D = $MapTiles

# map type
@export var data: MapTypeData

# tiles type
@export var available_tiles: Array[TileTypeData]
var tile_data_map: Dictionary = {}

# main map feature, grid[Vector2] = Tile object
var grid: Dictionary = {}

# map get reachables
var reachables: Array = []

func _ready() -> void:
	tile_data_map[0] = null
	for tile_res in available_tiles:
		if tile_res:
			tile_data_map[tile_res.type] = tile_res


func generate() -> void:
	for child in tiles.get_children():
		child.queue_free()
	grid.clear()

	var coords = _generate_map_tiles_coords(data.radius, data.base_shape)

	for coord in coords:
		var tile_enum = _get_random_tiletype(data.type_shape, coord)
		if tile_enum == -1: 
			continue #en cas d'erreur, aucune tuile ne sera generee

		var new_tile = TILE_SCENE.instantiate()
		var final_enum = tile_enum as g_enums.e_tile 
		
		new_tile.data = tile_data_map[final_enum]
		new_tile.type = final_enum
		
		tiles.add_child(new_tile)
		new_tile.setup(coord.x, coord.y) 
		new_tile.tile_clicked.connect(_on_tile_clicked)
		
		grid[coord] = new_tile
	
	_clean_isolated_tiles()


func _generate_map_tiles_coords(radius: int, shape: MapTypeData.MapShape) -> Array[Vector2]:
	var map_tiles_coord: Array[Vector2] = []
	
	match shape:
		MapTypeData.MapShape.RHOMBUS:
			for x in range(-radius, radius + 1):
				for y in range(-radius, radius + 1):
					var coord = Vector2(x, y)
					map_tiles_coord.append(coord)
		MapTypeData.MapShape.RECTANGLE:
			for x in range(-radius, radius + 1):
				for y in range(-radius - floor(x / 2.0) , radius - floor(x / 2.0)  + 1):
					var coord = Vector2(x, y)
					map_tiles_coord.append(coord)
		MapTypeData.MapShape.HEXAGON:
			for x in range(-radius, radius + 1):
				for y in range(max(-radius, -x - radius), min(radius, -x + radius) + 1):
					var coord = Vector2(x, y)
					map_tiles_coord.append(coord)
		MapTypeData.MapShape.CIRCLE:
			var r_sq = radius * radius
			var max_x = floor(radius * 2.0 / sqrt(3.0))
			for x in range(-max_x, max_x + 1):
				var delta = (4 * r_sq) - (3 * x * x)
				if delta < 0:
					continue 
				var y_min = ceil((-x - sqrt(delta)) / 2.0)
				var y_max = floor((-x + sqrt(delta)) / 2.0)
				for y in range(y_min, y_max + 1):
					map_tiles_coord.append(Vector2(x, y))
					
	return map_tiles_coord


func _get_random_tiletype(type: MapTypeData.MapType, coord: Vector2) -> int:
	var random_val = randf()
	match type:
		MapTypeData.MapType.LINE:
			var dist_from_line = abs(coord.y) 
			if dist_from_line > 1:
				var remaining_dist = dist_from_line - 1
				var remaining_radius = data.radius - 1
				if remaining_radius <= 0:
					return 0
				var ratio = float(remaining_dist) / float(remaining_radius)
				var survival_chance = 1.0 - (ratio * ratio)
				if randf() > survival_chance or random_val < 0.10:
					return 0
				elif random_val < 0.30:
					return 1
				else:
					return 2
					
		MapTypeData.MapType.CROSS:
			var dist_to_branch = min(abs(coord.x), abs(coord.x + coord.y))
			if dist_to_branch > 1:
				var dist_from_center = max(abs(coord.x), abs(coord.y), abs(-coord.x - coord.y))
				var noise = randf_range(0.0, 1.5)
				var taper_effect = float(dist_from_center) / (float(data.radius) * 1.5)
				var chaotic_dist = dist_to_branch + noise + taper_effect
				if chaotic_dist > 3.0:
					return 0
			if dist_to_branch == 0:
				return 2
			else:
				if random_val < 0.10: 
					return 0
				elif random_val < 0.30:
					return 1
				else:
					return 2
		MapTypeData.MapType.BALANCED:
			if random_val < 0.10: 
				return 0
			elif random_val < 0.30:
				return 1
			else:
				return 2

		MapTypeData.MapType.DENSE:
			var dist_from_center = max(abs(coord.x), abs(coord.y), abs(-coord.x - coord.y))
			if dist_from_center <= 1:
				return 2
			var frequency = 1.2
			var wave = sin(coord.x * frequency) + cos(coord.y * frequency) + sin((coord.x + coord.y) * frequency)
			wave += randf_range(-0.8, 0.8)
			if wave >= 0:
				return 1
			elif random_val < 0.10: 
				return 0
			else:
				return 2
		MapTypeData.MapType.MOUNTAIN:
			var dist_from_center = max(abs(coord.x), abs(coord.y), abs(-coord.x - coord.y))
			if dist_from_center <= data.radius / 2.2:
				return 1
			elif dist_from_center <= data.radius / 1.5:
				return 2
			elif random_val < 0.20:
				return 0
			elif random_val < 0.30:
				return 1
			else:
				return 2
			
		MapTypeData.MapType.LAKE:
			var dist_from_center = max(abs(coord.x), abs(coord.y), abs(-coord.x - coord.y))
			if dist_from_center <= data.radius / 2.2:
				return 0
			elif dist_from_center <= data.radius / 1.5:
				return 2
			elif random_val < 0.30:
				return 1
			else:
				return 2
			
		MapTypeData.MapType.CHAOS:
			var dist_from_center = max(abs(coord.x), abs(coord.y), abs(-coord.x - coord.y))
			if dist_from_center <= 1:
				return 2
			var frequency = 1.2
			var wave = sin(coord.x * frequency) + cos(coord.y * frequency) + sin((coord.x + coord.y) * frequency)
			wave += randf_range(-0.8, 0.8)
			if wave > 1.2:
				return 0
			elif random_val < 0.30: 
				return 1
			else:
				return 2
		_:
			if random_val < 0.10: 
				return 0
			elif random_val < 0.30:
				return 1
			else:
				return 2
				
	return 2


func _clean_isolated_tiles() -> void:
	var start_coord = Vector2.ZERO
	var min_dist = 99999
	
	for coord in grid.keys():
		if grid[coord].is_walkable:
			var dist = max(abs(coord.x), abs(coord.y), abs(-coord.x - coord.y))
			if dist < min_dist:
				min_dist = dist
				start_coord = coord
				if dist == 0:
					break
	
	var main_continent: Array = get_reachable_tiles(start_coord, 30, []).keys()
	
	for coord in grid.keys().duplicate():
		var tile = grid[coord]
		
		if tile.is_walkable:
			if not main_continent.has(coord):
				tile.queue_free()
				grid.erase(coord)
				
		else:
			var touches_continent = false
			for dir in HEX_DIRECTIONS:
				if main_continent.has(coord + dir):
					touches_continent = true
					break
					
			if not touches_continent:
				tile.queue_free()
				grid.erase(coord)

func generate_start_position(pawn_number: int) -> Array[Vector2]:
	var position_array: Array[Vector2]
	#TODO replace this by a random start map position finder
	for coord in grid.keys():
		var tile = get_tile(coord)
		if tile and tile.is_walkable:
			position_array.append(coord)
			pawn_number -= 1
		if pawn_number <= 0:
			break
	
	return position_array


func _on_tile_clicked(tile_instance: Tile) -> void:
	var coord = Vector2(tile_instance.q, tile_instance.r)
	grid_tile_clicked.emit(coord)

#
#func _on_tile_hovered(tile_instance: Tile) -> void:
	#var coord = Vector2(tile_instance.q, tile_instance.r)
	#grid_tile_hovered.emit(coord)


func get_tile(target_coord: Vector2) -> Tile:
	if grid.has(target_coord):
		return grid[target_coord]
	return null


func get_map_center() -> Vector2:
	if grid.is_empty():
		return Vector2.ZERO
		
	var min_pos = Vector2(INF, INF)
	var max_pos = Vector2(-INF, -INF)
	
	for tile in grid.values():
		var pos = tile.global_position
		
		min_pos.x = min(min_pos.x, pos.x)
		min_pos.y = min(min_pos.y, pos.y)
		max_pos.x = max(max_pos.x, pos.x)
		max_pos.y = max(max_pos.y, pos.y)
		
	return (min_pos + max_pos) / 2.0


func light_up_tiles(color: Color) -> void:
	for coord in reachables:
		grid[coord].set_reachable(true, color)


func clear_lights() -> void:
	for tile in grid.values():
		tile.set_reachable(false)


func map_clear() -> void:
	clear_lights()
	reachables.clear()


func set_reachable_tiles(start_coord: Vector2, distance: int, coords_to_avoid: Array) -> void:
	var reachable_tiles = get_reachable_tiles(start_coord, distance, coords_to_avoid)
	reachables = reachable_tiles.keys()


func set_field_of_view(start_coord: Vector2, range_min: int, range_max: int, coords_to_avoid: Array) -> void:
	reachables = get_field_of_view(start_coord, range_min, range_max, coords_to_avoid)


func get_reachable_tiles(start_coord: Vector2, distance: int, coords_to_avoid: Array) -> Dictionary:
	var came_from = {}

	if not grid.has(start_coord): 
		return came_from
		
	came_from[start_coord] = null
	var fringes = [[grid[start_coord]]]

	for k in range(1, distance + 1):
		fringes.append([])
		for hex in fringes[k - 1]:
			var hex_coord = Vector2(hex.q, hex.r)

			for dir in HEX_DIRECTIONS:
				var neighbor_coord = hex_coord + dir
				if grid.has(neighbor_coord):
					var neighbor = grid[neighbor_coord]

					if not came_from.has(neighbor_coord) and neighbor.is_walkable and not coords_to_avoid.has(neighbor_coord):
						came_from[neighbor_coord] = hex_coord
						fringes[k].append(neighbor)

	return came_from


func is_path_valid(distance: float, start_coord: Vector2, target_coord: Vector2, epsilon: Vector2, coords_to_avoid: Array) -> bool:
	if distance == 0:
		return true
	
	var start = start_coord + epsilon
	var target = target_coord + epsilon
	
	var path = true
	
	for i in range(1, distance):
		var lerp_t = float(i) / distance
		
		if path:
			var step_coord = start.lerp(target, lerp_t).round()
			if not grid.has(step_coord) or grid[step_coord].is_opaque or coords_to_avoid.has(step_coord):
				path = false
	
	return path


func is_tile_visible(start_coord: Vector2, target_coord: Vector2, coords_to_avoid: Array) -> bool:
	
	if (not grid.has(start_coord)) or (not grid.has(target_coord)):
		return false
	
	var distance = Math.get_distance(start_coord, target_coord)
	if distance == 0:
		return true
	
	var p_path = is_path_valid(distance, start_coord, target_coord, Vector2(1e-6, 1e-6), coords_to_avoid)
	var n_path = is_path_valid(distance, start_coord, target_coord, Vector2(-1e-6, -1e-6), coords_to_avoid)
	
	if not p_path and not n_path:
		return false

	return true


func get_field_of_view(start_coord: Vector2, range_min: int, range_max: int, coords_to_avoid: Array) -> Array:
	var fov = []
	
	if not grid.has(start_coord):
		return fov
		
	if range_min == 0:
		fov.append(start_coord)
	
	for cell in grid:
		if cell != start_coord and not grid[cell].is_opaque and is_tile_visible(start_coord, cell, coords_to_avoid):
			var distance = Math.get_distance(start_coord, cell)
			if distance >= range_min and distance <= range_max:
				fov.append(cell)

	return fov
