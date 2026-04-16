class_name TurnManager
extends Node

@onready var world: World = get_parent()
@export var timeline_ui: Timeline
var current_turn_order: Array = []

func start_combat(pawns: Array) -> void:
	current_turn_order = pawns.duplicate()
	
	current_turn_order.sort_custom(func(a: Pawn, b: Pawn): return a.current_init > b.current_init)
	
	world.current_pawn = current_turn_order[0]
	
	timeline_ui.generate_visuals(current_turn_order)

#je suppose qu'il faut faire un truc du style pour update tout le tour apres une action d'un joueur
func update_turn() -> void:
	current_turn_order.sort_custom(func(a: Pawn, b: Pawn): return a.current_init > b.current_init)
	
	world.current_pawn = current_turn_order[0]
	
	timeline_ui.generate_visuals(current_turn_order)
	
