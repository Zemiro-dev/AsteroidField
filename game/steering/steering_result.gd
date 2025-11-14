extends RefCounted
class_name SteeringResult


var acceleration: Vector2
var heading: Vector2


func _init(_acceleration: Vector2, _heading: Vector2):
	acceleration = _acceleration
	heading = _heading


func add(r: SteeringResult):
	acceleration += r.acceleration
	heading += r.heading


func limit_length(max_acceleration: float, max_speed: float):
	acceleration.limit_length(max_acceleration)
	heading.limit_length(max_speed)
