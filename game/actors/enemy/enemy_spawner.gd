extends Node2D
class_name EnemySpawner


@export var enemy_scene: PackedScene


func _ready() -> void:
	self_modulate = Color(0, 0, 0, 0);
	spawnAll()


func spawnAll() -> void:
	for child in get_children():
		if child is Marker2D:
			var enemy: Node2D = enemy_scene.instantiate()
			add_child(enemy)
			enemy.global_transform = child.global_transform
