extends Node2D
class_name FreeProjectileContainer


func _ready() -> void:
	GlobalSignals.request_projectile_spawn.connect(spawn)


func spawn(projectile: Node) -> void:
	add_child(projectile)
