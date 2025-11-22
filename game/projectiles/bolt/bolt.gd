extends Area2D
class_name Bolt


func _physics_process(delta: float) -> void:
	position += Vector2(200., 0.)
