class_name PawnManager
extends Node2D

const PAWN_SCENE = preload("res://Scenes/Objects/pawn.tscn")

@onready var timeline: Timeline = $TimelineHUD

var pawns: Dictionary = {}
var player_pawns: Array[Pawn] = []
var ai_pawns: Array[Pawn] = []

var turn_order: Array = []

var current_pawn: Pawn = null

#changer ça en truc plus generique
@export var data_ally: PawnTypeData
@export var data_enemy: PawnTypeData


func _ready() -> void:
	#je met ici le player main character a la main, mais ça devra sans doute les generer d'apres TOUT le tableau
	player_pawns.append(PAWN_SCENE.instantiate())


func generate() -> int:
	# creates all pawns (generate enemy pawns)
	# TODO change following :

	for pawn in ai_pawns:	
		pawn.queue_free()
	ai_pawns.clear()
	
	#TODO replace this par un random ?
	var num_enemies = 2
	
	for i in range(num_enemies):
		var new_pawn = PAWN_SCENE.instantiate()
		ai_pawns.append(new_pawn)
		
	return player_pawns.size() + ai_pawns.size()


func spawn_pawns(positions: Array[Vector2], global_positions: Array[Vector2]) -> void:
	
	if positions.size() < (player_pawns.size() + ai_pawns.size()):
		push_error("ERROR_SPAWN")
		return
		
	var pos_index = 0
	
	#spawn first player pawns
	for i in range(player_pawns.size()):
		var p = player_pawns[i]
		p.data = data_ally
		p.global_position = global_positions[pos_index]
		p.coord = positions[pos_index]
		
		add_child(p)
		pawns[positions[pos_index]] = p
		
		pos_index += 1
		
	#spawn enemy pawns
	for i in range(ai_pawns.size()):
		var e = ai_pawns[i]
		e.data = data_enemy
		e.global_position = global_positions[pos_index]
		e.coord = positions[pos_index]
		
		add_child(e)
		pawns[positions[pos_index]] = e
		
		pos_index += 1


func get_pawn_at(coord: Vector2) -> Pawn:
	if pawns.has(coord):
		return pawns[coord]
	return null


func update_turn_order() -> void:
	turn_order = pawns.values().duplicate()
	turn_order.sort_custom(func(a: Pawn, b: Pawn): return a.current_init > b.current_init)
	current_pawn = turn_order[0]
	timeline.generate_visuals(turn_order)


func move_pawn(pawn: Pawn, new_coord: Vector2) -> void:
	pawns.erase(pawn.coord)
	pawn.coord = new_coord
	pawns[new_coord] = pawn
