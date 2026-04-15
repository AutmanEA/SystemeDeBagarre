class_name PawnTypeData
extends Resource

@export var pawn_name: String = "Unknown"

#hp
#arme melee
#arme range
#slot 1
#slot 2
#slot 3

#TEMPORARY : TODO replace this by weapon ranges
@export var tmp_min_range: int = 1
@export var tmp_max_range: int = 4

@export var init: int = 20

#speed = movement range
@export var speed: int = 3

@export_category("Colors")
@export var color: Color = Color.WHITE
