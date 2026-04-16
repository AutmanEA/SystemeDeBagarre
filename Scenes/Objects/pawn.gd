class_name Pawn
extends Area2D

signal pawn_clicked(pawn_instance: Pawn)

@export var sprite_offset: float = 850.0

@onready var sprite_top = $Pawn_Top
@onready var sprite_border = $Pawn_Border
@onready var sprite_thickness = $Pawn_Thickness

var is_hovered: bool = false
var is_selected: bool = false

var current_init: int

var q: int
var r: int

@export var data: PawnTypeData

func _ready() -> void:
	input_event.connect(_on_input_event)
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	
	setup()
	
	_update_visuals()

func setup():
	sprite_top.position.y = -sprite_offset
	sprite_border.position.y = -sprite_offset
	sprite_thickness.position.y = -sprite_offset
	$BaseCollision.position.y = -sprite_offset
	$Figurine.position.y = -sprite_offset
	
	$Pawn_Thickness.self_modulate = data.color
	$Pawn_Border.self_modulate = data.color
	$Pawn_Top.self_modulate = data.color
	
	current_init = data.init


func do_something(cost: int) -> bool:
	"""returns true if action is done"""
	if cost > current_init:
		return false
	
	current_init -= cost
	return true

func set_hex_coords(_q: int, _r: int) -> void:
	q = _q
	r = _r

func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		pawn_clicked.emit(self)
		get_viewport().set_input_as_handled()

func _on_mouse_entered() -> void:
	is_hovered = true
	_update_visuals()

func _on_mouse_exited() -> void:
	is_hovered = false
	_update_visuals()

func set_selected(selected: bool) -> void:
	is_selected = selected
	_update_visuals()

func _update_visuals() -> void:
	if is_selected:
		sprite_border.self_modulate = Color.RED
		sprite_thickness.self_modulate = Color.RED
	elif is_hovered:
		sprite_border.self_modulate = Color.WHITE
		sprite_thickness.self_modulate = Color.WHITE
	else:
		sprite_border.self_modulate = Color(sprite_top.self_modulate).darkened(0.1)
		sprite_thickness.self_modulate = Color(sprite_top.self_modulate).darkened(0.1)
