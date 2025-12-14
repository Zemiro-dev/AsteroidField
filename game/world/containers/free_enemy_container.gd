extends Node2D
class_name FreeEnemyContainer


func _ready() -> void:
	GlobalSignals.request_enemy_spawn.connect(spawn)


func spawn(enemy: Node) -> void:
	add_child(enemy)
