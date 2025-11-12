extends Node


func clamp_vector2_length(v: Vector2, max_length: float) -> Vector2:
	if v.length() > max_length:
		return v.normalized() * max_length
	return v
