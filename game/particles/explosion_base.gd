extends GPUParticles2D


@export var sound_scene: PackedScene


func _ready() -> void:
	finished.connect(on_finished)
	GlobalSignals.request_world_sound_spawn.emit(self, sound_scene)


func on_finished():
	queue_free()
