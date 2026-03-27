class_name Tuile
extends Sprite2D


var q
var r
var s
var size = 32/2

func _init(_q, _r):
	self.q = _q
	self.r = _r
	self.s = -_q - _r
	self.texture = load("res://assets/gemini-svg.svg")

func pointy_hex_to_pixel():
	# hex to cartesian
	var position = Vector2.ZERO
	
	position.x = (sqrt(3) * self.q + sqrt(3)/2 * self.r) * self.size
	position.y = (3./2 * self.r) * self.size
	
	return position
