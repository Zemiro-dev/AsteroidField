extends GPUParticles2D


func _ready() -> void:
	finished.connect(on_finished)


func on_finished():
	queue_free()
