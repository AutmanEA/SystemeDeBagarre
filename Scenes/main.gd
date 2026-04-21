class_name World
extends Node

@onready var select_manager = $SelectManager
@onready var action_manager = $ActionManager

@onready var map_manager: Map = $Map
@onready var pawn_manager: PawnManager = $PawnManager

@onready var hud: ActionsHUD = $ActionsHUD

@onready var camera: Camera2D = $Camera2D

var selected_tile: Tile = null
var selected_pawn: Pawn = null

enum e_game_state {
	NEUTRAL,
	MOVING,
	ATTACKING_MELEE,
	ATTACKING_RANGE
	}
var current_state: e_game_state = e_game_state.NEUTRAL

func _ready() -> void:
	
	_setup_battle()
	
	#setup du tour de jeu
	pawn_manager.update_turn_order()
	
	#selection setup
	map_manager.grid_tile_clicked.connect(_on_tile_clicked)
	
	#setup camera
	camera.global_position = map_manager.get_map_center()
	
	#setup action HUD
	hud.action_selected.connect(_on_hud_action_selected)


func _setup_battle() -> void:
	var pawn_count = pawn_manager.generate()
	map_manager.generate()
	
	var positions: Array[Vector2] = map_manager.generate_start_position(pawn_count)
	var global_positions: Array[Vector2] = []
	for i in range(len(positions)):
		global_positions.append(map_manager.get_tile(positions[i]).global_position)
	
	pawn_manager.spawn_pawns(positions, global_positions)


func _on_tile_clicked(clicked_object) -> void:
	if action_manager.current_state != action_manager.e_game_state.NEUTRAL:
		action_manager.action_watcher(Vector2(clicked_object.x, clicked_object.y), pawn_manager.current_pawn)
	else:
		select_manager.handle_selection(Vector2(clicked_object.x, clicked_object.y))


func _on_object_clicked(clicked_object) -> void:
	if action_manager.current_state != action_manager.e_game_state.NEUTRAL:
		action_manager.action_watcher(Vector2(clicked_object.q, clicked_object.r), pawn_manager.current_pawn)
	else:
		select_manager.handle_selection(Vector2(clicked_object.q, clicked_object.r))


func _on_hud_action_selected(action: String) -> void:
	if pawn_manager.current_pawn == null:
		return
	action_manager.action_clear()
	match action:
		"move":
			current_state = e_game_state.MOVING
		"melee":
			current_state = e_game_state.ATTACKING_MELEE
		"range":
			current_state = e_game_state.ATTACKING_RANGE
	action_manager.action_preparation(pawn_manager.current_pawn)
