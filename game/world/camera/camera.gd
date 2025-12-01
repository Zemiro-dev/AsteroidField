extends Camera2D
class_name CoreCamera

@export var offset_tracking_rate := 2.
var shake_offset := Vector2.ZERO
var shake_strength := 0.0
var shake_timer := 0.0


func _ready() -> void:
	GlobalSignals.request_camera_shake.connect(shake)


func shake(duration: float, strength: float):
	shake_timer = duration
	shake_strength = strength


func next_shake_offset() -> Vector2:
	if shake_timer > 0.0:
		return Vector2(
			randf_range(-1, 1) * shake_strength,
			randf_range(-1, 1) * shake_strength
		)
	else:
		return shake_offset.lerp(Vector2.ZERO, .5)

func _process(delta: float) -> void:
	shake_offset = next_shake_offset()
	if shake_timer > 0.0: shake_timer -= delta
	offset = offset.lerp(shake_offset, offset_tracking_rate * delta)
