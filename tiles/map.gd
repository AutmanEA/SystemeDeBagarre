extends Node


var map = [
	1, 1, 1, 1, 1, 1,
	1, 2, 0, 0, 0, 1,
	1, 1, 1, 1, 1, 1
]


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var sprite = Sprite2D.new()
	sprite.texture.set("res://TileSet_asset/Characters/kare01.png")
	sprite.position = Vector2(0, 0)
	sprite.show()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
