class_name TurnManager
extends Node

@onready var world = get_parent()
@export var timeline_ui: Timeline
var current_turn_order: Array = []

func start_combat(all_pawns: Array) -> void:
	current_turn_order = all_pawns.duplicate()
	
	# (Ici plus tard : tu pourras trier le tableau avec un custom sort 
	# pour mettre le pion le plus rapide en premier)
	
	timeline_ui.generate_visuals(current_turn_order)
