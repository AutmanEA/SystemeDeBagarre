class_name ActionManager
extends Node

@onready var world = get_parent()

enum e_game_state {
	NEUTRAL,
	MOVING,
	ATTACKING_MELEE,
	ATTACKING_RANGE
	}

var current_state: e_game_state = e_game_state.NEUTRAL
var reachable_tiles: Dictionary = {}

func _on_hud_action_selected(action: String) -> void:
	match action:
		"move":
			if world.current_pawn != null:
				current_state = e_game_state.MOVING
		"melee":
			current_state = e_game_state.ATTACKING_MELEE
		"range":
			current_state = e_game_state.ATTACKING_RANGE
	action_preparation()

func action_preparation():
	match current_state:
		e_game_state.MOVING:
			var start = Vector2(world.current_pawn.q, world.current_pawn.r)
			reachable_tiles = PathfindingHelper.get_reachable_tiles(world.grid, world.pawns, start, 3)
			for coord in reachable_tiles.keys():
				world.grid[coord].set_reachable(true, Color.LIGHT_BLUE)
			
		e_game_state.ATTACKING_MELEE:
			pass
			
		e_game_state.ATTACKING_RANGE:
			pass
			
		e_game_state.NEUTRAL:
			pass


func action_watcher(target_coord: Vector2) -> void:
	match current_state:
		e_game_state.MOVING:
			action_move(target_coord)
			
		e_game_state.ATTACKING_MELEE:
			action_melee()
			
		e_game_state.ATTACKING_RANGE:
			action_range()
			
		e_game_state.NEUTRAL:
			pass

	reachable_tiles.clear()
	current_state = e_game_state.NEUTRAL

func action_move(target_coord: Vector2) -> void:

	var current_coord: Vector2 = Vector2(world.current_pawn.q, world.current_pawn.r)

	if current_state != e_game_state.MOVING:
		return

	if reachable_tiles.has(target_coord):
		
		#var path = PathfindingHelper.reconstruct_path(target_coord, reachable_tiles)
		world.pawns.erase(current_coord) 
		world.pawns[target_coord] = world.current_pawn
		world.current_pawn.set_hex_coords(int(target_coord.x), int(target_coord.y))

		for c in reachable_tiles.keys():
			world.grid[c].set_reachable(false)
		
		world.current_pawn.position = world.grid[target_coord].position

func action_melee():
	print("melee")

func action_range():
	print("range")
