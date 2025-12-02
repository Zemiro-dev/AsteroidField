extends Node2D
class_name FreeCollectibleContainer


func _ready() -> void:
	GlobalSignals.request_collectible_spawn.connect(unpack_and_spawn_collectible)


func unpack_and_spawn_collectible(position: Vector2, scene: PackedScene) -> void:
	if scene and scene.can_instantiate():
		var instantiated_scene = scene.instantiate()
		if instantiated_scene is Collectible:
			instantiated_scene.global_position = position
			add_child.call_deferred(instantiated_scene)
