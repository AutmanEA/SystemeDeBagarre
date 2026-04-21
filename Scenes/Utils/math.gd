class_name Math
extends RefCounted

static func get_distance(a: Vector2, b: Vector2) -> float:
	var sub = a - b
	return (abs(sub.x) + abs(sub.x + sub.y) + abs(sub.y)) / 2.0
