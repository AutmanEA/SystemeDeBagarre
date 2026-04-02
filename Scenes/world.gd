extends Node

const TILE_SCENE = preload("res://Scenes/tile.tscn")

@export var data_wall: TileTypeData
@export var data_floor: TileTypeData
@export var data_ally: TileTypeData

@onready var tile_data_map = {
	g_enums.e_tile.Null: null,
	g_enums.e_tile.Wall: data_wall,
	g_enums.e_tile.Floor: data_floor,
	g_enums.e_tile.Ally: data_floor,
}

var selected_tile: Tile = null

const map = [
	[0,0,1,1,1,1,1,1,1,0,0,0],
	[0,0,1,1,1,1,1,0,0,0,0,1,1,0],
	[0,0,1,1,1,1,1,0,1,1,1,1,0,1],
	[0,1,2,2,2,2,2,3,2,2,2,2,2,1,1,1,1,1,1],
	[1,1,2,2,2,2,2,2,2,2,2,2,1,1],
	[1,1,2,2,2,2,2,2,2,2,2,2,1,1],
	[1,1,2,2,2,2,2,2,2,2,2,2,1,1],
	[1,1,2,2,2,2,2,2,2,2,2,2,1,1],
	[1,1,2,2,2,2,2,2,2,2,2,2,1,1],
	[1,1,2,2,2,2,2,2,2,2,2,2,1,1],
	[1,1,2,2,2,2,2,2,2,2,2,2,1,1],
	[1,1,2,2,2,2,2,2,2,2,2,2,1,1],
	[1,1,2,2,2,2,2,2,2,2,2,2,1,1],
	[1,1,2,2,2,2,2,2,2,2,2,2,1,1],
	[1,1,2,2,2,2,2,2,2,2,2,2,1,1],
	[1,1,2,2,2,2,2,2,2,2,2,2,1,1],
	[1,1,2,2,2,2,2,2,2,2,2,2,1,1],
	[1,1,2,2,2,2,2,2,2,2,2,2,1,1],
	[1,1,2,2,2,2,2,2,2,2,2,2,1,1],
	[1,1,2,2,2,2,2,2,2,2,2,2,1,1],
	[1,1,2,2,2,2,2,2,2,2,2,2,1,1],
	[0,0,1,1,1,1,1,1,1,1,1,1,1,0],
]


func _ready() -> void:
	generate_map(map)

func _process(_delta: float) -> void:
	pass
	
	
func generate_map(map_brute):
	for r in range(map_brute.size()):
		for q in range(map_brute[r].size()):
			var new_tile = TILE_SCENE.instantiate()
			var tile_enum = map_brute[r][q] as g_enums.e_tile
			new_tile.data = tile_data_map[tile_enum]
			new_tile.type = tile_enum
			add_child(new_tile)
			new_tile.setup(q, r)
			new_tile.tile_clicked.connect(_on_tile_clicked)

func _on_tile_clicked(tile_instance: Tile) -> void:
	if selected_tile != null:
		selected_tile.set_selected(false)
	
	if selected_tile != tile_instance:
		tile_instance.set_selected(true)
		selected_tile = tile_instance
	else:
		selected_tile = null
