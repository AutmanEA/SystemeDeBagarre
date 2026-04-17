class_name World
extends Node

const PAWN_SCENE = preload("res://Scenes/Objects/pawn.tscn")

#var grid: Dictionary = {}
var pawns: Dictionary = {}

@onready var select_manager = $SelectManager
@onready var action_manager = $ActionManager
@onready var turn_manager = $TurnManager
@onready var map_manager: Map = $Map

@onready var hud: ActionsHUD = $ActionsHUD

@onready var camera: Camera2D = $Camera2D

@export var data_ally: PawnTypeData
@export var data_enemy: PawnTypeData


var selected_tile: Tile = null
var selected_pawn: Pawn = null
var current_pawn: Pawn = null




func _ready() -> void:
	map_manager.grid_tile_clicked.connect(_on_tile_clicked)
	
	map_manager.generate()
	spawn_pawn(4, 5, data_ally)
	spawn_pawn(6, 7, data_enemy)
	#spawn_pawn(7, 5, data_enemy) #1v1 pour l'instant c'est pas mal
	
	camera.global_position = map_manager.get_map_center()
	
	
	#remplacer par un truc qui find le premier avec le plus grand init pour le current pawn
	#current_pawn = pawns[Vector2(4, 5)]
	
	var all_pawns = pawns.values()
	
	turn_manager.start_combat(all_pawns)
	#quand un tour est fini ca doit changer le current pawn
	
	hud.action_selected.connect(action_manager._on_hud_action_selected)


func _process(_delta: float) -> void:
	pass

func _on_tile_clicked(clicked_object) -> void:
	if action_manager.current_state != action_manager.e_game_state.NEUTRAL:
		action_manager.action_watcher(Vector2(clicked_object.x, clicked_object.y))
	else:
		select_manager.handle_selection(Vector2(clicked_object.x, clicked_object.y))


func _on_object_clicked(clicked_object) -> void:
	if action_manager.current_state != action_manager.e_game_state.NEUTRAL:
		action_manager.action_watcher(Vector2(clicked_object.q, clicked_object.r))
	else:
		select_manager.handle_selection(Vector2(clicked_object.x, clicked_object.y))


func spawn_pawn(target_q: int, target_r: int, pawn_data: PawnTypeData) -> void:
	var coord = Vector2(target_q, target_r)
	
	var target_tile = map_manager.get_tile(coord)
	if target_tile == null or not target_tile.is_walkable:
		push_warning("ERROR_SPAWN")
		return
		
	var new_pawn = PAWN_SCENE.instantiate()
	
	
	new_pawn.data = pawn_data
	
	new_pawn.position = target_tile.position
	new_pawn.set_hex_coords(target_q, target_r)
	new_pawn.pawn_clicked.connect(_on_object_clicked)
	
	add_child(new_pawn)
	
	pawns[coord] = new_pawn
