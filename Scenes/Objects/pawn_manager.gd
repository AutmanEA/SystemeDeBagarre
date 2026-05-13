class_name PawnManager
extends Node2D

signal grid_pawns_clicked(coord: Vector2)

const PAWN_SCENE = preload("res://Scenes/Objects/pawn.tscn")

@onready var timeline: Timeline = $TimelineHUD

var pawns: Dictionary = {}
var player_pawns: Array[Pawn] = []

var turn_order: Array = []

var current_pawn: Pawn = null

#changer ça en truc plus generique
@export var data_ally: PawnTypeData

#TODO donc ça faudrait que ce soit un tableau de data_enemy je suppose ?
#en tout cas me faut un autre moyen d'avoir plsuieurs types de data_enemy différents
@export var data_enemy: PawnTypeData

var enemies: Array[PawnTypeData] = []

func _ready() -> void:
	#je met ici le player main character a la main,
	#mais faudra sans doute que y ait un truc de creation de personnage
	add_player_pawn(data_ally)
	add_player_pawn(data_ally)


func add_player_pawn(pawn_data: PawnTypeData) -> void:
	#permet, lors d'un event ajout de pawn, d'ajouter un pawn permanent a la liste,
	#genre le hero principal a la creation du perso va s'ajouter en permanence ici
	var new_pawn: Pawn = PAWN_SCENE.instantiate()
	
	new_pawn.data = pawn_data
	new_pawn.pawn_clicked.connect(_on_pawn_clicked)
	player_pawns.append(new_pawn)


func generate() -> int:
	# creates all pawns (generate enemy pawns)
	# TODO change following :

	#TODO replace this par un random ?
	
	#TODO systeme de selection de datas d'ennemis, selon difficulté, étage...
	#TODO systeme de room? genre selon la room tu spawn x ou y
	#for i in range(enemy_count):
	enemies.append(data_enemy)
	enemies.append(data_enemy)
		
	return player_pawns.size() + enemies.size()


func spawn_pawns(positions: Array[Vector2], global_positions: Array[Vector2]) -> void:
	
	if positions.size() < (player_pawns.size() + enemies.size()):
		push_error("ERROR_SPAWN")
		return
		
	var pos_index = 0
	
	#spawn first player pawns
	for i in range(player_pawns.size()):
		var p = player_pawns[i]
		p.global_position = global_positions[pos_index]
		p.coord = positions[pos_index]
		
		add_child(p)
		pawns[positions[pos_index]] = p
		
		pos_index += 1
		
	#spawn enemy pawns
	for i in range(enemies.size()):
		var new_pawn: Pawn = PAWN_SCENE.instantiate()
		new_pawn.data = enemies[i]
		new_pawn.global_position = global_positions[pos_index]
		new_pawn.coord = positions[pos_index]
		new_pawn.pawn_clicked.connect(_on_pawn_clicked)
		
		add_child(new_pawn)
		pawns[positions[pos_index]] = new_pawn
		
		pos_index += 1


func kill_pawn(pawn_coord: Vector2) -> void:
	var pawn = pawns[pawn_coord]
	pawn.queue_free()
	pawns.erase(pawn_coord)


func get_pawn_at(coord: Vector2) -> Pawn:
	if pawns.has(coord):
		return pawns[coord]
	return null


func update_turn_order() -> void:
	turn_order = pawns.values().duplicate()
	turn_order.sort_custom(func(a: Pawn, b: Pawn): return a.current_init > b.current_init)
	current_pawn = turn_order[0]
	timeline.generate_visuals(turn_order)


func move_pawn(pawn: Pawn, new_coord: Vector2, new_position: Vector2) -> void:
	pawns.erase(pawn.coord)
	pawn.coord = new_coord
	pawn.global_position = new_position
	pawns[new_coord] = pawn


func _on_pawn_clicked(pawn_instance: Pawn) -> void:
	grid_pawns_clicked.emit(pawn_instance.coord)
