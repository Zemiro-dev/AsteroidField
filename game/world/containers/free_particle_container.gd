extends Node2D
class_name FreeParticleContainer


func _ready() -> void:
	GlobalSignals.request_particle_spawn.connect(spawn)


func spawn(particle: Node) -> void:
	add_child(particle)
