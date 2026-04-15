class_name TurnManager
extends Node

@onready var world = get_parent()
@export var timeline_ui: Timeline
var current_turn_order: Array = []

func start_combat(pawns: Array) -> void:
	current_turn_order = pawns.duplicate()
	
	current_turn_order.sort_custom(func(a, b): return a.data.init > b.data.init)
	
	timeline_ui.generate_visuals(current_turn_order)

#je suppose qu'il faut faire un truc du style pour update tout le tour apres une action d'un joueur
func update_turn() -> void:
	current_turn_order.sort_custom(func(a, b): return a.data.init > b.data.init)
	timeline_ui.generate_visuals(current_turn_order)
	
