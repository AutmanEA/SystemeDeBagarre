class_name SelectManager
extends Node

@onready var world = get_parent() 

var selected_tile: Tile = null
var selected_pawn: Pawn = null

func handle_selection(target_coord: Vector2) -> void:
	clear_selection(selected_tile)
	clear_selection(selected_pawn)
	if world.map_manager.grid.has(target_coord):
		selected_tile = world.map_manager.grid[target_coord]
		selected_tile.set_selected(true)

	if world.pawn_manager.pawns.has(target_coord):
		selected_pawn = world.pawns[target_coord]
		selected_pawn.set_selected(true)

func clear_selection(selected_object) -> void:
	if selected_object != null:
		selected_object.set_selected(false)
		selected_object = null
