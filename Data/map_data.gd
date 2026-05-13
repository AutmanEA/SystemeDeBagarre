class_name MapTypeData
extends Resource

enum MapShape {
	CIRCLE,
	HEXAGON,
	RECTANGLE,
	RHOMBUS,
}

enum MapType {
	BALANCED,
	DENSE,
	MOUNTAIN,
	LAKE,
	LINE,
	CROSS,
	CHAOS
}

enum StartType {
	GROUPED,
	SEPARATED,
	SURROUNDED,
	OPPOSED
}

@export var map_name: String = "Unknown"

#biome? -> pour modifier les types de tiles
#epoch?

@export var base_shape: MapShape = MapShape.CIRCLE
@export var type_shape: MapType = MapType.BALANCED
@export_range(1,50) var radius: int = 5

@export var start_type: StartType = StartType.GROUPED
@export var start_distance: int = 0
