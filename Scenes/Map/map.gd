class_name Map
extends Node2D

signal grid_tile_clicked(coord: Vector2)
signal grid_tile_hovered(coord: Vector2)

const TILE_SCENE = preload("res://Scenes/Map/tile.tscn")
const HEX_DIRECTIONS = [
	Vector2(1, 0), Vector2(1, -1), Vector2(0, -1), 
	Vector2(-1, 0), Vector2(-1, 1), Vector2(0, 1)
]

# loads tiles objects
@onready var tiles: Node2D = $Tiles

# tiles type
@export var available_tiles: Array[TileTypeData]
var tile_data_map: Dictionary = {}

# main map feature, grid[Vector2] = Tile object
var grid: Dictionary = {}


func _ready() -> void:
	tile_data_map[0] = null
	for tile_res in available_tiles:
		if tile_res:
			tile_data_map[tile_res.type] = tile_res


func generate() -> void:
	# TODO random map generator
	const map = [
		[0,0,1,1,1,1,1,1,1,0,0,0,0,0],
		[0,0,1,1,1,1,1,0,0,0,0,1,1,0],
		[0,0,1,1,1,1,1,0,1,1,1,1,0,1],
		[0,1,2,2,2,2,2,2,2,1,2,2,2,1],
		[1,1,2,2,2,2,2,2,2,1,2,2,1,1],
		[1,1,2,2,2,1,1,2,2,2,2,2,1,1],
		[1,1,2,1,2,2,0,2,2,2,2,2,1,1],
		[1,1,2,2,2,2,2,2,2,2,2,2,1,1],
		[1,1,2,2,2,2,2,2,2,2,2,2,1,1],
		[0,0,1,1,1,1,1,1,1,1,1,1,1,0],
	]
	
	for child in tiles.get_children():
		child.queue_free()
	grid.clear()
	
	for r in range(map.size()):
		for q in range(map[r].size()):
			var new_tile = TILE_SCENE.instantiate()
			var tile_enum = map[r][q] as g_enums.e_tile
			new_tile.data = tile_data_map[tile_enum]
			
			new_tile.type = tile_enum
			
			tiles.add_child(new_tile)
			new_tile.setup(q, r)
			
			new_tile.tile_clicked.connect(_on_tile_clicked)
			
			var coord = Vector2(q, r)
			grid[coord] = new_tile


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


func _on_tile_hovered(tile_instance: Tile) -> void:
	var coord = Vector2(tile_instance.q, tile_instance.r)
	grid_tile_hovered.emit(coord)


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


func light_up_tiles(reachables: Array, color: Color) -> void:
	for coord in reachables:
		grid[coord].set_reachable(true, color)


func clear_lights() -> void:
	for tile in grid.values():
		tile.set_reachable(false)


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
