class_name Math
extends RefCounted

static func get_distance(a: Vector2, b: Vector2) -> float:
	var sub = a - b
	return (abs(sub.x) + abs(sub.x + sub.y) + abs(sub.y)) / 2.0

static func hex_round(frac: Vector2) -> Vector2:
	# 1. Conversion Axiale -> Cubique
	var q = frac.x
	var r = frac.y
	var s = -q - r
	
	# 2. Arrondi basique
	var rq = round(q)
	var rr = round(r)
	var rs = round(s)
	
	# 3. Calcul des différences pour compenser le glissement
	var q_diff = abs(rq - q)
	var r_diff = abs(rr - r)
	var s_diff = abs(rs - s)
	
	# 4. On corrige l'axe qui a subi la plus grande déformation
	if q_diff > r_diff and q_diff > s_diff:
		rq = -rr - rs
	elif r_diff > s_diff:
		rr = -rq - rs
	else:
		rs = -rq - rr
		
	# 5. Retour en Axiale
	return Vector2(rq, rr)
