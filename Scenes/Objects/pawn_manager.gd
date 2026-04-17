class_name PawnManager
extends Node2D

const PAWN_SCENE = preload("res://Scenes/Objects/pawn.tscn")

var pawns: Dictionary = {}


func spawn_pawn(coord: Vector2, pixel_pos: Vector2, data: PawnTypeData) -> void:
	if pawns.has(coord):
		push_error("ERROR_SPAWN")
		return
		
	var new_pawn = PAWN_SCENE.instantiate()
	new_pawn.data = data
	new_pawn.global_position = pixel_pos
	new_pawn.q = coord.x
	new_pawn.r = coord.y
	
	add_child(new_pawn)
	
	pawns[coord] = new_pawn


func get_pawn_at(coord: Vector2) -> Pawn:
	if pawns.has(coord):
		return pawns[coord]
	return null


func move_pawn(pawn: Pawn, new_coord: Vector2) -> void:
	var old_coord = Vector2(pawn.q, pawn.r)
	
	pawns.erase(old_coord)
	
	pawn.q = new_coord.x
	pawn.r = new_coord.y
	
	pawns[new_coord] = pawn
	
