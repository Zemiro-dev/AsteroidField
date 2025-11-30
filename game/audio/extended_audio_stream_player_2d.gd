extends AudioStreamPlayer2D
class_name ExtendedAudioStreamPlayer2D


@export var pitch_jitter: float = 0.1
@export var one_shot: bool = false

@onready var original_pitch: float = pitch_scale


func _ready() -> void:
	if one_shot:
		finished.connect(func() -> void: queue_free())


func play_at_random_pitch() -> void:
	var new_pitch: float = original_pitch + [-pitch_jitter, 0, pitch_jitter].pick_random()
	pitch_scale = new_pitch
	play()
