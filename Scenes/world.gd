extends Node

const TILE_SCENE = preload("res://Scenes/tile.tscn")
const PAWN_SCENE = preload("res://Scenes/pawn.tscn")

var grid: Dictionary = {}
var pawns: Dictionary = {}

enum e_game_state { NEUTRAL, MOVING, ATTACKING }

var current_state: e_game_state = e_game_state.NEUTRAL

@onready var hud: Hud = $Hud

@export var data_wall: TileTypeData
@export var data_floor: TileTypeData
@export var data_ally: TileTypeData

@onready var path_line: Line2D = $PathLine

@onready var tile_data_map = {
	g_enums.e_tile.Null: null,
	g_enums.e_tile.Wall: data_wall,
	g_enums.e_tile.Floor: data_floor,
	g_enums.e_tile.Ally: data_floor,
}

var selected_tile: Tile = null
var selected_pawn: Pawn = null
var current_pawn: Pawn = null

const map = [
	[0,0,1,1,1,1,1,1,1,0,0,0,0,0],
	[0,0,1,1,1,1,1,0,0,0,0,1,1,0],
	[0,0,1,1,1,1,1,0,1,1,1,1,0,1],
	[0,1,2,2,2,2,2,3,2,1,2,2,2,1],
	[1,1,2,2,2,2,2,2,2,1,2,2,1,1],
	[1,1,2,2,2,1,1,2,2,2,2,2,1,1],
	[1,1,2,2,2,2,2,2,2,2,2,2,1,1],
	[1,1,2,2,2,2,2,2,2,2,2,2,1,1],
	[1,1,2,2,2,2,2,2,2,2,2,2,1,1],
	[0,0,1,1,1,1,1,1,1,1,1,1,1,0],
]

var current_reachable_tiles: Dictionary = {}

const HEX_DIRECTIONS = [
	Vector2(1, 0), Vector2(1, -1), Vector2(0, -1), 
	Vector2(-1, 0), Vector2(-1, 1), Vector2(0, 1)
]

func _ready() -> void:
	generate_map(map)
	spawn_pawn(4, 5)
	
	current_pawn = pawns[Vector2(4, 5)]
	
	
	hud.action_selected.connect(_on_hud_action_selected)

func _process(_delta: float) -> void:
	pass
	
func _on_hud_action_selected(action: String) -> void:
	match action:
		"move":
			if current_pawn != null:
				current_state = e_game_state.MOVING
				current_reachable_tiles = get_reachable_tiles(current_pawn, 3)
				print("Mode DÉPLACEMENT activé pour le pion en ", current_pawn.q, ",", current_pawn.r)
				for coord in current_reachable_tiles.keys():
					grid[coord].set_reachable(true)
			else:
				print("Sélectionnez d'abord un pion !")
		"attack":
			current_state = e_game_state.ATTACKING


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
			new_tile.tile_hovered.connect(_on_tile_hovered)
			
			var coord = Vector2(q, r)
			grid[coord] = new_tile
			
func _on_tile_hovered(hovered_tile: Tile) -> void:
	var coord = Vector2(hovered_tile.q, hovered_tile.r)

	# Si on est en mode déplacement et que la case est valide
	if current_state == e_game_state.MOVING and current_reachable_tiles.has(coord):
		var path_coords = reconstruct_path(coord)
		path_line.clear_points()

		# On trace la ligne point par point
		for c in path_coords:
			# On la lève de -15 pixels pour qu'elle flotte au-dessus du sol (et pas à l'intérieur)
			path_line.add_point(grid[c].position + Vector2(0, -15))
	else:
		# Si on survole une case interdite, on efface la ligne
		path_line.clear_points()

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
	match current_state:
		# MODE NEUTRE : On sélectionne juste les choses (comme avant)
		e_game_state.NEUTRAL:
			_clear_selection()
			if grid.has(target_coord):
				selected_tile = grid[target_coord]
				selected_tile.set_selected(true)
				
			if pawns.has(target_coord):
				selected_pawn = pawns[target_coord]
				selected_pawn.set_selected(true)
		# MODE DÉPLACEMENT : On clique pour bouger !
		e_game_state.MOVING:
			if current_reachable_tiles.has(target_coord):
				print("On déplace le pion vers : ", target_coord)
					
				# 1. On récupère le chemin sous forme de liste de coordonnées
				var path = reconstruct_path(target_coord)
					
				# 2. Mise à jour LOGIQUE immédiate
				var origin_coord = Vector2(current_pawn.q, current_pawn.r)
				pawns.erase(origin_coord) 
				pawns[target_coord] = current_pawn
				current_pawn.set_hex_coords(int(target_coord.x), int(target_coord.y))
					
				# 3. Nettoyage VISUEL immédiat (On efface le HUD pour montrer qu'on a validé l'action)
				for c in current_reachable_tiles.keys():
					grid[c].set_reachable(false)
				path_line.clear_points()
				
				# 4. L'ANIMATION SUR LE CHEMIN
				var tween = create_tween()
				current_pawn.z_index = 10 # On passe au-dessus des tuiles
				
				# On boucle sur chaque étape du chemin
				for step_coord in path:
					var target_pos = grid[step_coord].position
					
					# On ajoute une étape d'animation pour chaque case
					# 0.2 secondes par case, en linéaire pour garder une vitesse constante
					tween.tween_property(current_pawn, "position", target_pos, 0.2).set_trans(Tween.TRANS_LINEAR)
				
				# 5. Le Callback : Une fois TOUT le chemin terminé
				tween.tween_callback(func(): 
					current_pawn.z_index = 0
					current_reachable_tiles.clear()
					current_state = e_game_state.NEUTRAL
				)
				
			else:
				print("Déplacement impossible : Case non accessible.")
				current_reachable_tiles.clear()
				current_state = e_game_state.NEUTRAL

func get_reachable_tiles(start_pawn: Pawn, movement: int) -> Dictionary:
	var came_from = {}
	var start_coord = Vector2(start_pawn.q, start_pawn.r)

	if not grid.has(start_coord): 
		return came_from
		
	came_from[start_coord] = null
	var fringes = [[grid[start_coord]]]

	for k in range(1, movement + 1):
		fringes.append([])
		for hex in fringes[k - 1]:
			var hex_coord = Vector2(hex.q, hex.r)

			for dir in HEX_DIRECTIONS:
				var neighbor_coord = hex_coord + dir
				if grid.has(neighbor_coord):
					var neighbor = grid[neighbor_coord]

					if not came_from.has(neighbor_coord) and neighbor.is_walkable and not pawns.has(neighbor_coord):
						came_from[neighbor_coord] = hex_coord
						fringes[k].append(neighbor)
							
	return came_from

# --- NOUVELLE FONCTION ---
# Elle lit le dictionnaire à l'envers pour recréer le chemin du but jusqu'au départ
func reconstruct_path(target_coord: Vector2) -> Array[Vector2]:
	var path: Array[Vector2] = []
	var current = target_coord
	
	# Tant qu'on n'est pas remonté au point de départ (qui vaut null)
	while current != null:
		path.append(current)
		# On passe au parent de la case actuelle
		current = current_reachable_tiles[current] 
		
	path.reverse() # On remet dans le bon sens (Départ -> Arrivée)
	return path

func _clear_selection() -> void:
	if selected_tile != null:
		selected_tile.set_selected(false)
		selected_tile = null
		
	if selected_pawn != null:
		selected_pawn.set_selected(false)
		selected_pawn = null
