extends Node



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	generer_plateau(6)
	pass # Replace with function body.



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func generer_plateau(nombre_de_tuiles):
	for x in range(nombre_de_tuiles):
		for y in range(nombre_de_tuiles):
			var new_tuile = Tuile.new(x, y)
			new_tuile.position = new_tuile.pointy_hex_to_pixel()
			add_child(new_tuile)
			
