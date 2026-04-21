class_name Map
extends Node2D

signal grid_tile_clicked(coord: Vector2)
signal grid_tile_hovered(coord: Vector2)

const TILE_SCENE = preload("res://Scenes/Map/tile.tscn")

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
		if pawn_number == 0:
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
