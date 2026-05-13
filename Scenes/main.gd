class_name World
extends Node

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
	map_manager.grid_tile_clicked.connect(_on_object_clicked)
	pawn_manager.grid_pawns_clicked.connect(_on_object_clicked)
	
	#setup camera
	camera.global_position = map_manager.get_map_center()
	
	#setup action HUD
	hud.action_selected.connect(_on_hud_action_selected)



func _setup_battle() -> void:
	var pawn_count = pawn_manager.generate()
	map_manager.generate()
	
	var positions: Array[Vector2] = map_manager.generate_start_position()
	var global_positions: Array[Vector2] = []
	for i in range(len(positions)):
		global_positions.append(map_manager.get_tile(positions[i]).global_position)
	
	pawn_manager.spawn_pawns(positions, global_positions)


func _on_object_clicked(clicked_object: Vector2) -> void:
	if current_state != e_game_state.NEUTRAL:
		action_watcher(clicked_object, pawn_manager.current_pawn)
	else:
		handle_selection(clicked_object)


func _on_hud_action_selected(action: String) -> void:
	if pawn_manager.current_pawn == null:
		return
	map_manager.map_clear()
	match action:
		"move":
			current_state = e_game_state.MOVING
		"melee":
			current_state = e_game_state.ATTACKING_MELEE
		"range":
			current_state = e_game_state.ATTACKING_RANGE
	action_preparation()



func handle_selection(target_coord: Vector2) -> void:
	clear_selection(selected_tile)
	clear_selection(selected_pawn)
	if map_manager.grid.has(target_coord):
		selected_tile = map_manager.grid[target_coord]
		selected_tile.set_selected(true)

	if pawn_manager.pawns.has(target_coord):
		selected_pawn = pawn_manager.pawns[target_coord]
		selected_pawn.set_selected(true)


func clear_selection(selected_object) -> void:
	if selected_object != null:
		selected_object.set_selected(false)
		selected_object = null





func action_preparation():
	var current_pawn = pawn_manager.current_pawn
	var pawns_positions = pawn_manager.pawns.keys()
	
	var light_color: Color = Color.WHITE
	
	match current_state:
		e_game_state.MOVING:
			var movement = pawn_manager.current_pawn.get_current_max_movement()
			map_manager.set_reachable_tiles(current_pawn.coord, movement, pawns_positions)
			light_color = Color.CADET_BLUE
			
		e_game_state.ATTACKING_MELEE:
			var min_range = 1
			var max_range = 1
			map_manager.set_field_of_view(current_pawn.coord, min_range, max_range, pawns_positions)
			light_color = Color.YELLOW
			
		e_game_state.ATTACKING_RANGE:
			var min_range = current_pawn.data.tmp_min_range
			var max_range = current_pawn.data.tmp_max_range
			map_manager.set_field_of_view(current_pawn.coord, min_range, max_range, pawns_positions)
			light_color = Color.YELLOW
	
		e_game_state.NEUTRAL:
			pass
	
	map_manager.light_up_tiles(light_color)


func action_watcher(target_coord: Vector2, current_pawn: Pawn) -> void:
	var cost: int = get_action_cost(target_coord, current_pawn)
	var allow_action = current_pawn.do_something(cost)
	if not allow_action:
		print("not enough init")
		return
	
	print(current_pawn.data.init, "/", current_pawn.current_init)

	match current_state:
		e_game_state.MOVING:
			print("ATTENTION JE VAIS BOUGER")
			action_move(target_coord, current_pawn)
			
		e_game_state.ATTACKING_MELEE:
			action_melee(target_coord)
			
		e_game_state.ATTACKING_RANGE:
			action_range(target_coord)
			
		e_game_state.NEUTRAL:
			pass

	current_state = e_game_state.NEUTRAL
	pawn_manager.update_turn_order()

func get_action_cost(target_coord: Vector2, current_pawn: Pawn) -> int:
	
	# TODO : replace all const values by weapons values and other things for moving
	match current_state:
		e_game_state.MOVING:
			var current_coord: Vector2 = current_pawn.coord
			var distance = Math.get_distance(current_coord, target_coord)

			print("ca va me couter de l'init mais...")
			return 1 + distance
		e_game_state.ATTACKING_MELEE:
			return 4
		e_game_state.ATTACKING_RANGE:
			return 6
		e_game_state.NEUTRAL:
			return 0
		_:
			return 0

func action_move(target_coord: Vector2, current_pawn: Pawn) -> void:
	if current_state != e_game_state.MOVING:
		return
		
	if map_manager.reachables.has(target_coord):
		print("VOILA JE BOUUUUGE")
		pawn_manager.move_pawn(current_pawn, target_coord, map_manager.grid[target_coord].global_position)

	map_manager.map_clear()

func action_melee(target_coord) -> void:
	
	if current_state != e_game_state.ATTACKING_MELEE:
		return
	
	if pawn_manager.pawns.has(target_coord) and map_manager.reachables.has(target_coord):
		print("y a un méchant je le tape EN MELEE")
		pawn_manager.kill_pawn(target_coord)

	map_manager.map_clear()


func action_range(target_coord) -> void:
	
	if current_state != e_game_state.ATTACKING_RANGE:
		return
	
	if pawn_manager.pawns.has(target_coord) and map_manager.reachables.has(target_coord):
		print("y a un méchant je le tape A DISTANCE")
		pawn_manager.kill_pawn(target_coord)

	map_manager.map_clear()
