class_name Tile
extends Area2D

signal tile_clicked(tile_instance)
signal tile_hovered(tile_instance)

@export var data: TileTypeData

const hex_width = 128.0
const hex_height = 128.0

var q
var r

@export var type : g_enums.e_tile = g_enums.e_tile.Null
@export var is_walkable = false
@export var is_selected = false
@export var is_hovered = false

@export var altitude: float = 0.0 # On remplace la constante par une variable
@export var color_variation: float = 0.1 # 10% de variation de couleur

@onready var outline: Line2D = $Tile_Outline
@onready var poly_sprite: Polygon2D = $Tile_Sprite

func _ready() -> void:
	outline.points = poly_sprite.polygon
	_update_visuals()
	pass # Replace with function body.


func _process(_delta: float) -> void:
	pass


func setup(_q : int, _r : int):
	self.q = _q
	self.r = _r
	
	self.scale = Vector2(1.0, 0.5)
	self.position = hex_to_pixel_position()
	self.input_pickable = true
	
	setup_type()
	
	return self

func setup_type():
	if data == null:
		self.hide()
		self.input_pickable = false
		return

	self.is_walkable = data.is_walkable
	self.input_pickable = data.is_pickable
	$Tile_Sprite.z_index = data.z_order
	
	altitude = randf_range(data.altitude_min, data.altitude_max)
	$Tile_CollisionPolygon.position.y = -altitude
	$Tile_Sprite.position.y = -altitude
	
	var target_color = Color.WHITE
	if data.base_colors.size() > 0:
		if data.base_colors.size() == 1:
			target_color = _get_varied_color(data.base_colors[0])
		else:
			var pattern = posmod(q - r, data.base_colors.size())
			target_color = data.base_colors[pattern]

	$Tile_Sprite.color = target_color
	
	$Tile_Thickness.modulate = target_color.darkened(data.thickness_darken)
	$Tile_Thickness.polygon[0].y -= altitude
	$Tile_Thickness.polygon[1].y -= altitude
	$Tile_Thickness.polygon[2].y -= altitude

func _update_visuals() -> void:
	if is_selected:
		# poly_sprite.self_modulate = Color.DIM_GRAY -> VISUEL A METTRE A JOUR ?
		outline.width = 3.0
		outline.position.y = poly_sprite.position.y - 1
	elif is_hovered and input_pickable:
		outline.width = 2.0
		outline.default_color = Color.WHITE_SMOKE
		outline.position.y = poly_sprite.position.y - 2
	else:
		outline.width = 0.0
		outline.z_index = 0
		poly_sprite.self_modulate = Color.WHITE


func hex_to_pixel_position() -> Vector2:
	var tile_position = Vector2.ZERO
	
	tile_position.x = (hex_width * self.q) + ((hex_width / 2.0) * self.r)
	tile_position.y = ((hex_height * 0.75) * self.r) * 0.5
	
	return tile_position

func _get_varied_color(base_color: Color) -> Color:
	var color_r = base_color.r + randf_range(-color_variation, color_variation)
	var color_g = base_color.g + randf_range(-color_variation, color_variation)
	var color_b = base_color.b + randf_range(-color_variation, color_variation)
	return Color(color_r, color_g, color_b).clamp()

func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		# TODO: lancer une fonction qui permet d'afficher les infos qqpart dans le HUD,
		# uniquement si y a des choses dedans je suppose, genre un effet particulier...,
		# ou alors tout le temps et ça donne la range par rapport au personnage en cours
		print_own_info() # temporaire
		tile_clicked.emit(self)

func print_own_info():
	print("Tile position -> ", self.q, " ", self.r)
	print("Tile type -> ", self.data.tile_name)

func _on_mouse_entered() -> void:
	is_hovered = true
	_update_visuals()
	tile_hovered.emit(self)

func _on_mouse_exited() -> void:
	is_hovered = false
	_update_visuals()

func set_selected(selected: bool) -> void:
	is_selected = selected
	_update_visuals()

func set_reachable(reachable: bool, color: Color = Color.WHITE) -> void:
	if reachable:
		self.modulate = color
	else:
		self.modulate = Color.WHITE

func set_targetable(targetable: bool, color: Color = Color.WHITE) -> void:
	if targetable:
		self.modulate = color
	else:
		self.modulate = Color.WHITE
