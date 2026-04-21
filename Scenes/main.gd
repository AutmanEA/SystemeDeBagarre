class_name World
extends Node

@onready var select_manager = $SelectManager

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
	if current_state != e_game_state.NEUTRAL:
		action_watcher(Vector2(clicked_object.x, clicked_object.y), pawn_manager.current_pawn)
	else:
		select_manager.handle_selection(Vector2(clicked_object.x, clicked_object.y))


func _on_object_clicked(clicked_object) -> void:
	if current_state != e_game_state.NEUTRAL:
		action_watcher(Vector2(clicked_object.q, clicked_object.r), pawn_manager.current_pawn)
	else:
		select_manager.handle_selection(Vector2(clicked_object.q, clicked_object.r))


func _on_hud_action_selected(action: String) -> void:
	if pawn_manager.current_pawn == null:
		return
	action_clear()
	match action:
		"move":
			current_state = e_game_state.MOVING
		"melee":
			current_state = e_game_state.ATTACKING_MELEE
		"range":
			current_state = e_game_state.ATTACKING_RANGE
	action_preparation()





var reachable_tiles: Dictionary = {}
var targetable_tiles: Array = []


func action_clear():
	
	map_manager.clear_lights()
	
	targetable_tiles.clear()
	reachable_tiles.clear()

func action_preparation():
	var current_pawn = pawn_manager.current_pawn
	var pawns_positions = pawn_manager.pawns.keys()
	
	var tiles_to_light: Array = []
	var light_color: Color = Color.WHITE
	
	match current_state:
		e_game_state.MOVING:
			var movement = pawn_manager.current_pawn.get_current_max_movement()
			tiles_to_light = map_manager.get_reachable_tiles(current_pawn.coord, movement, pawns_positions).keys()
			light_color = Color.CADET_BLUE
			
		e_game_state.ATTACKING_MELEE:
			var min_range = 1
			var max_range = 1
			tiles_to_light = map_manager.get_field_of_view(current_pawn.coord, min_range, max_range, pawns_positions)
			light_color = Color.YELLOW
			
		e_game_state.ATTACKING_RANGE:
			var min_range = current_pawn.data.tmp_min_range
			var max_range = current_pawn.data.tmp_max_range
			tiles_to_light = map_manager.get_field_of_view(current_pawn.coord, min_range, max_range, pawns_positions)
			light_color = Color.YELLOW
	
		e_game_state.NEUTRAL:
			pass
	
	map_manager.light_up_tiles(tiles_to_light, light_color)


func action_watcher(target_coord: Vector2, current_pawn) -> void:
	var cost: int = get_action_cost(target_coord, current_pawn)
	var allow_action = current_pawn.do_something(cost)
	if not allow_action:
		print("not enough init")
		return
	
	print(current_pawn.data.init, "/", current_pawn.current_init)

	match current_state:
		e_game_state.MOVING:
			action_move(target_coord, current_pawn)
			
		e_game_state.ATTACKING_MELEE:
			action_melee(target_coord)
			
		e_game_state.ATTACKING_RANGE:
			action_range(target_coord)
			
		e_game_state.NEUTRAL:
			pass

	current_state = e_game_state.NEUTRAL
	pawn_manager.update_turn_order()

func get_action_cost(target_coord: Vector2, current_pawn) -> int:
	
	# TODO : replace all const values by weapons values and other things for moving
	match current_state:
		e_game_state.MOVING:
			var current_coord: Vector2 = current_pawn.coord
			var distance = PathfindingHelper.new(map_manager.grid, pawn_manager.pawns).get_tile_distance(current_coord.x - target_coord.x, current_coord.y - target_coord.y)

			return 1 + distance
		e_game_state.ATTACKING_MELEE:
			return 4
		e_game_state.ATTACKING_RANGE:
			return 6
		e_game_state.NEUTRAL:
			return 0
		_:
			return 0

func action_move(target_coord: Vector2, current_pawn) -> void:

	var current_coord: Vector2 = current_pawn.coord
	if current_state != e_game_state.MOVING:
		return

	if reachable_tiles.has(target_coord):
		
		#var path = PathfindingHelper.reconstruct_path(target_coord, reachable_tiles)
		pawn_manager.pawns.erase(current_coord) 
		pawn_manager.pawns[target_coord] = current_pawn
		current_pawn.coord = target_coord
		current_pawn.position = map_manager.grid[target_coord].position

	action_clear()

func action_melee(target_coord) -> void:
	
	if current_state != e_game_state.ATTACKING_MELEE:
		return
	
	if pawn_manager.pawns.has(target_coord) and targetable_tiles.has(target_coord):
		print("y a un méchant je le tape EN MELEE")
		var enemy_pawn = pawn_manager.pawns[target_coord]
		enemy_pawn.queue_free()
		pawn_manager.pawns.erase(target_coord)

	action_clear()

func action_range(target_coord) -> void:
	
	if current_state != e_game_state.ATTACKING_RANGE:
		return
		
	if pawn_manager.pawns.has(target_coord) and targetable_tiles.has(target_coord):
		print("y a un méchant je le tape A DISTANCE")
		var enemy_pawn = pawn_manager.pawns[target_coord]
		enemy_pawn.queue_free()
		pawn_manager.pawns.erase(target_coord)

	action_clear()
