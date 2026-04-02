extends Node

const TILE_SCENE = preload("res://Scenes/tile.tscn")
const PAWN_SCENE = preload("res://Scenes/pawn.tscn")

var grid: Dictionary = {}
var pawns: Dictionary = {}

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
var selected_pawn: Pawn = null

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
	spawn_pawn(4, 5)

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
			
			# NOUVEAU : On sauvegarde la tuile dans le dictionnaire
			var coord = Vector2(q, r)
			grid[coord] = new_tile


#func _on_tile_clicked(tile_instance: Tile) -> void:
	#if selected_tile != null:
		#selected_tile.set_selected(false)
	#
	#if selected_tile != tile_instance:
		#tile_instance.set_selected(true)
		#selected_tile = tile_instance
	#else:
		#selected_tile = null
#
#
#func _on_pawn_clicked(pawn_instance: Pawn) -> void:
	#if selected_pawn != null:
		#selected_pawn.set_selected(false)
	#
	#if selected_pawn != pawn_instance:
		#pawn_instance.set_selected(true)
		#selected_pawn = pawn_instance
	#else:
		#selected_pawn = null

func spawn_pawn(target_q: int, target_r: int) -> void:
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
	new_pawn.position = grid[coord].position
	new_pawn.set_hex_coords(target_q, target_r)
	new_pawn.pawn_clicked.connect(_on_pawn_clicked)
	
	# 4. On l'ajoute à l'arbre de scène (en tant que frère des tuiles)
	add_child(new_pawn)
	
	# 5. On l'enregistre dans notre dictionnaire de pions
	pawns[coord] = new_pawn

# --- ÉCOUTEURS DE CLICS ---

func _on_tile_clicked(clicked_tile: Tile) -> void:
	var coord = Vector2(clicked_tile.q, clicked_tile.r)
	_handle_selection(coord)

func _on_pawn_clicked(clicked_pawn: Pawn) -> void:
	var coord = Vector2(clicked_pawn.q, clicked_pawn.r)
	_handle_selection(coord)

# --- LE CERVEAU DE LA SÉLECTION ---

func _handle_selection(target_coord: Vector2) -> void:
	# Cas 1 : Le joueur clique sur la case qui est DÉJÀ sélectionnée
	if selected_tile != null and Vector2(selected_tile.q, selected_tile.r) == target_coord:
		_clear_selection()
		return
		
	# Cas 2 : Le joueur clique sur une NOUVELLE case
	_clear_selection() # On éteint proprement l'ancienne sélection
	
	# A. On allume la tuile cible
	if grid.has(target_coord):
		selected_tile = grid[target_coord]
		selected_tile.set_selected(true)
		
	# B. On allume le pion cible (s'il y en a un sur cette case !)
	if pawns.has(target_coord):
		selected_pawn = pawns[target_coord]
		selected_pawn.set_selected(true)
		print("Pion et Tuile sélectionnés en : ", target_coord)
	else:
		print("Tuile vide sélectionnée en : ", target_coord)

# Fonction utilitaire pour tout éteindre proprement
func _clear_selection() -> void:
	if selected_tile != null:
		selected_tile.set_selected(false)
		selected_tile = null
		
	if selected_pawn != null:
		selected_pawn.set_selected(false)
		selected_pawn = null
