extends Node2D
class_name CannonHardpoint


const BOLT_CANNON = preload("res://projectiles/bolt/bolt_cannon.tscn")


func add_cannon(cannon_scene: PackedScene, wielder: Node2D = null):
	if cannon_scene and cannon_scene.can_instantiate():
		var cannon := cannon_scene.instantiate()
		if cannon is Cannon:
			cannon.wielder = wielder
			add_child(cannon)
