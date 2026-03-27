extends Node

class_name Tile

enum content {
	FREE,		#nothing on the tile
	WALL,		#wall avoid walking through and not movable
	TARGET,		#alive entity that can act alone (people, animal...)
	OBJECT,		#entity that can't act alone (movable object, walkable object like a trap...)
	COVER		#covers avoid 50% distance damages
}

enum effect {
	NONE = 100,	
	BURN = 200,
	POISON = 300,
	SLOW = 400,
}

var pos: Vector3:
	set(value):
		pos.x = value.x
		pos.y = value.y
		pos.z = value.z
	get():
		return pos

var active_effect = effect.NONE
var active_content = content.FREE
