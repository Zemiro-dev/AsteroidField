extends Node


func clamp_vector2_length(v: Vector2, max_length: float):
	if v.length() > max_length:
		v = v.normalized() * max_length
