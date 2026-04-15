extends Node

const TILE_SCENE = preload("res://Scenes/tile.tscn")
const PAWN_SCENE = preload("res://Scenes/pawn.tscn")

var grid: Dictionary = {}
var pawns: Dictionary = {}

@onready var select_manager = $SelectManager
@onready var action_manager = $ActionManager

@onready var hud: Hud = $Hud

@export var data_wall: TileTypeData
@export var data_floor: TileTypeData

@export var data_ally: PawnTypeData
@export var data_enemy: PawnTypeData

@onready var tile_data_map = {
	g_enums.e_tile.Null: null,
	g_enums.e_tile.Wall: data_wall,
	g_enums.e_tile.Floor: data_floor,
}

var selected_tile: Tile = null
var selected_pawn: Pawn = null
var current_pawn: Pawn = null

const map = [
	[0,0,1,1,1,1,1,1,1,0,0,0,0,0],
	[0,0,1,1,1,1,1,0,0,0,0,1,1,0],
	[0,0,1,1,1,1,1,0,1,1,1,1,0,1],
	[0,1,2,2,2,2,2,2,2,1,2,2,2,1],
	[1,1,2,2,2,2,2,2,2,1,2,2,1,1],
	[1,1,2,2,2,1,1,2,2,2,2,2,1,1],
	[1,1,2,1,2,2,2,2,2,2,2,2,1,1],
	[1,1,2,2,2,2,2,2,2,2,2,2,1,1],
	[1,1,2,2,2,2,2,2,2,2,2,2,1,1],
	[0,0,1,1,1,1,1,1,1,1,1,1,1,0],
]


func _ready() -> void:
	generate_map(map)
	spawn_pawn(4, 5, data_ally)
	spawn_pawn(6, 7, data_enemy)
	spawn_pawn(7, 5, data_enemy)
	
	current_pawn = pawns[Vector2(4, 5)]
	
	
	hud.action_selected.connect(action_manager._on_hud_action_selected)

func _process(_delta: float) -> void:
	pass
	
func _on_object_hovered(hovered_object) -> void:
	hovered_object._update_visuals()

func _on_object_clicked(clicked_object) -> void:
	var coord = Vector2(clicked_object.q, clicked_object.r)
	if action_manager.current_state != action_manager.e_game_state.NEUTRAL:
		action_manager.action_watcher(coord)
	else:
		select_manager.handle_selection(coord)

func generate_map(map_brute):
	for r in range(map_brute.size()):
		for q in range(map_brute[r].size()):
			var new_tile = TILE_SCENE.instantiate()
			var tile_enum = map_brute[r][q] as g_enums.e_tile
			
			new_tile.data = tile_data_map[tile_enum]
			new_tile.type = tile_enum
			
			add_child(new_tile)
			new_tile.setup(q, r)
			new_tile.tile_clicked.connect(_on_object_clicked)
			new_tile.tile_hovered.connect(_on_object_hovered)
			
			var coord = Vector2(q, r)
			grid[coord] = new_tile
			

func spawn_pawn(target_q: int, target_r: int, pawn_data: PawnTypeData) -> void:
	var coord = Vector2(target_q, target_r)
	
	# 1. Vérifications de sécurité
	if not grid.has(coord):
		push_warning("Impossible de spawner : La tuile ", coord, " n'existe pas.")
		return
		
	if not grid[coord].is_walkable:
		push_warning("Impossible de spawner : La tuile ", coord, " n'est pas un sol praticable.")
		return
		
	if pawns.has(coord):
		push_warning("Impossible de spawner : Il y a déjà un pion en ", coord)
		return

	# 2. Création du pion
	var new_pawn = PAWN_SCENE.instantiate()
	
	# 3. Placement ! 
	# On triche intelligemment : au lieu de recalculer les maths (hex_to_pixel),
	# on copie directement la position de la tuile cible !
	
	new_pawn.data = pawn_data
	
	new_pawn.position = grid[coord].position
	new_pawn.set_hex_coords(target_q, target_r)
	new_pawn.pawn_clicked.connect(_on_object_clicked)
	
	# 4. On l'ajoute à l'arbre de scène (en tant que frère des tuiles)
	add_child(new_pawn)
	
	# 5. On l'enregistre dans notre dictionnaire de pions
	pawns[coord] = new_pawn
