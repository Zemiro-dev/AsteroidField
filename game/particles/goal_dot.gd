extends GPUParticles2D
class_name GoalDot

@onready var animation_player: AnimationPlayer = $AnimationPlayer
var is_fading := false

func fadeout():
	if !is_fading:
		is_fading = true
		animation_player.play("fadeout")
