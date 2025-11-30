extends Node2D
class_name FreeParticleContainer


func _ready() -> void:
	GlobalSignals.request_particle_spawn.connect(spawn)
	GlobalSignals.request_explosion_spawn.connect(unpack_and_spawn_explosion)


func spawn(particle: Node) -> void:
	add_child(particle)


func unpack_and_spawn_explosion(source: Node2D, explosion_scene: PackedScene) -> void:
	if explosion_scene and explosion_scene.can_instantiate():
		var explosion = explosion_scene.instantiate()
		if explosion is GPUParticles2D or explosion is CPUParticles2D:
			explosion.global_transform = source.global_transform
			explosion.emitting = true
			GlobalSignals.request_particle_spawn.emit(explosion)
