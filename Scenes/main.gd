class_name World
extends Node

#const PAWN_SCENE = preload("res://Scenes/Objects/pawn.tscn")

#var grid: Dictionary = {}
#var pawns: Dictionary = {}

@onready var select_manager = $SelectManager
@onready var action_manager = $ActionManager
@onready var turn_manager = $TurnManager

@onready var map_manager: Map = $Map
@onready var pawn_manager: PawnManager = $PawnManager

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

	_spawn(Vector2(4, 5), data_ally)
	_spawn(Vector2(6, 7), data_enemy)
	
	camera.global_position = map_manager.get_map_center()
	
	
	#remplacer par un truc qui find le premier avec le plus grand init pour le current pawn
	#current_pawn = pawns[Vector2(4, 5)]
	
	var all_pawns = pawn_manager.pawns.values()
	
	turn_manager.start_combat(all_pawns)
	#quand un tour est fini ca doit changer le current pawn
	
	hud.action_selected.connect(action_manager._on_hud_action_selected)


func _spawn(coord: Vector2, data: PawnTypeData) -> void:
	var target_tile = map_manager.get_tile(coord)
	if target_tile and target_tile.is_walkable:
		pawn_manager.spawn_pawn(coord, target_tile.global_position, data)

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
		select_manager.handle_selection(Vector2(clicked_object.q, clicked_object.r))
