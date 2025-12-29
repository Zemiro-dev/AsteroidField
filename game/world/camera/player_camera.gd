extends Camera2D
class_name PlayerCamera

@export var camera_speed := 12.
@export var max_distance := 200.
@export var offset_tracking_rate := 2.
var shake_offset := Vector2.ZERO
var shake_strength := 0.0
var shake_timer := 0.0
var player: Player:
	set(value):
		player = value


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

func _physics_process(delta: float) -> void:
	shake_offset = next_shake_offset()
	if shake_timer > 0.0: shake_timer -= delta
	offset = offset.lerp(shake_offset, offset_tracking_rate * delta)
	if player:
		var next_position := global_position.lerp(player.global_position, camera_speed * delta)
		if next_position.distance_to(player.global_position) > max_distance:
			next_position = player.global_position + (player.global_position.direction_to(next_position) * max_distance)
		global_position = next_position
