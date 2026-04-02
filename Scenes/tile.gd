class_name Tile
extends Area2D

signal tile_clicked(tile_instance)

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

@onready var original_thickness_polygon = $Tile_Thickness.polygon.duplicate()
@onready var outline: Line2D = $Tile_Outline
@onready var poly_sprite: Polygon2D = $Tile_Sprite

func _ready() -> void:

	
	outline.points = poly_sprite.polygon
	_update_outline()
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

	var new_poly = original_thickness_polygon.duplicate()
	new_poly[0].y -= altitude
	new_poly[1].y -= altitude
	new_poly[2].y -= altitude
	$Tile_Thickness.polygon = new_poly

func _update_outline() -> void:
	if is_selected:
		var pattern = posmod(q - r, data.base_colors.size())
		var selected_color = Color.DIM_GRAY
		poly_sprite.self_modulate = selected_color
		outline.width = 0.0
	elif is_hovered and input_pickable:
		outline.width = 2.0
		outline.default_color = Color.WHITE
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
	# On fait varier légèrement le Rouge, Vert et Bleu
	var color_r = base_color.r + randf_range(-color_variation, color_variation)
	var color_g = base_color.g + randf_range(-color_variation, color_variation)
	var color_b = base_color.b + randf_range(-color_variation, color_variation)
	return Color(color_r, color_g, color_b).clamp() # clamp() évite de dépasser le blanc pur ou le noir

func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		print_own_info()
		tile_clicked.emit(self)
		get_viewport().set_input_as_handled()


func print_own_info():
	print("Tile position -> ", self.q, " ", self.r)
	print("Tile type -> ", self.data.tile_name)


func _on_mouse_entered() -> void:
	is_hovered = true
	_update_outline()

func _on_mouse_exited() -> void:
	is_hovered = false
	_update_outline()

func set_selected(selected: bool) -> void:
	is_selected = selected
	_update_outline()
