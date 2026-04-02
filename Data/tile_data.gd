class_name TileTypeData
extends Resource

@export var tile_name: String = "Unknown"
@export var is_walkable: bool = false
@export var is_pickable: bool = true

@export_category("Altitude")
@export var altitude_min: float = 0.0
@export var altitude_max: float = 0.0

@export_category("Colors")
@export var base_colors: Array[Color] = [Color.WHITE]
@export var thickness_darken: float = 0.55
