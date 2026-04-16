class_name ActionManager
extends Node

@onready var world: World = get_parent()

enum e_game_state {
	NEUTRAL,
	MOVING,
	ATTACKING_MELEE,
	ATTACKING_RANGE
	}

var current_pawn: Pawn
var current_state: e_game_state = e_game_state.NEUTRAL
var reachable_tiles: Dictionary = {}
var targetable_tiles: Array = []

func _on_hud_action_selected(action: String) -> void:
	current_pawn = world.current_pawn
	if current_pawn == null:
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

func action_clear():
	for c in reachable_tiles.keys():
		world.grid[c].set_reachable(false)
		
	for c in targetable_tiles:
		world.grid[c].set_targetable(false)
		
	targetable_tiles.clear()
	reachable_tiles.clear()

func action_preparation():
	var start = Vector2(current_pawn.q, current_pawn.r)
	var pathfinder = PathfindingHelper.new(world.grid, world.pawns)
	match current_state:
		e_game_state.MOVING:
			var max_movement: int
			if world.pawns[start].data.speed < current_pawn.current_init:
				max_movement = world.pawns[start].data.speed
			else:
				max_movement = current_pawn.current_init - 1
			reachable_tiles = pathfinder.get_reachable_tiles(start, max_movement)
			for coord in reachable_tiles.keys():
				world.grid[coord].set_reachable(true, Color.LIGHT_BLUE)
			
		e_game_state.ATTACKING_MELEE:
			targetable_tiles = pathfinder.get_field_of_view(start, 1, 1)
			for coord in targetable_tiles:
				world.grid[coord].set_targetable(true, Color.YELLOW)
			
		e_game_state.ATTACKING_RANGE:
			targetable_tiles = pathfinder.get_field_of_view(start, world.pawns[start].data.tmp_min_range, world.pawns[start].data.tmp_max_range)
			for coord in targetable_tiles:
				world.grid[coord].set_targetable(true, Color.YELLOW)
			
		e_game_state.NEUTRAL:
			pass

signal action_signal(nombre: int)

func action_watcher(target_coord: Vector2) -> void:
	var cost: int = get_action_cost(target_coord)
	var allow_action = current_pawn.do_something(cost)
	if not allow_action:
		print("not enough init")
		return
	
	print(current_pawn.data.init, "/", current_pawn.current_init)

	match current_state:
		e_game_state.MOVING:
			action_move(target_coord)
			
		e_game_state.ATTACKING_MELEE:
			action_melee(target_coord)
			
		e_game_state.ATTACKING_RANGE:
			action_range(target_coord)
			
		e_game_state.NEUTRAL:
			pass

	current_state = e_game_state.NEUTRAL
	world.turn_manager.update_turn()

func get_action_cost(target_coord: Vector2) -> int:
	
	# TODO : replace all const values by weapons values and other things for moving
	match current_state:
		e_game_state.MOVING:
			var current_coord: Vector2 = Vector2(current_pawn.q, current_pawn.r)
			var distance = PathfindingHelper.new(world.grid, world.pawns).get_tile_distance(current_coord.x - target_coord.x, current_coord.y - target_coord.y)

			return 1 + distance
		e_game_state.ATTACKING_MELEE:
			return 4
		e_game_state.ATTACKING_RANGE:
			return 6
		e_game_state.NEUTRAL:
			return 0
		_:
			return 0

func action_move(target_coord: Vector2) -> void:

	var current_coord: Vector2 = Vector2(current_pawn.q, current_pawn.r)

	if current_state != e_game_state.MOVING:
		return

	if reachable_tiles.has(target_coord):
		
		#var path = PathfindingHelper.reconstruct_path(target_coord, reachable_tiles)
		world.pawns.erase(current_coord) 
		world.pawns[target_coord] = current_pawn
		current_pawn.set_hex_coords(int(target_coord.x), int(target_coord.y))
		current_pawn.position = world.grid[target_coord].position

	action_clear()

func action_melee(target_coord) -> void:
	
	if current_state != e_game_state.ATTACKING_MELEE:
		return
	
	if world.pawns.has(target_coord) and targetable_tiles.has(target_coord):
		print("y a un méchant je le tape EN MELEE")
		var enemy_pawn = world.pawns[target_coord]
		enemy_pawn.queue_free()
		world.pawns.erase(target_coord)

	action_clear()

func action_range(target_coord) -> void:
	
	if current_state != e_game_state.ATTACKING_RANGE:
		return
		
	if world.pawns.has(target_coord) and targetable_tiles.has(target_coord):
		print("y a un méchant je le tape A DISTANCE")
		var enemy_pawn = world.pawns[target_coord]
		enemy_pawn.queue_free()
		world.pawns.erase(target_coord)

	action_clear()
