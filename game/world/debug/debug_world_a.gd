extends Node2D


@onready var player: Player = $Player
@onready var health: TextureProgressBar = $UI/Health
@onready var boost: TextureProgressBar = $UI/Boost


func _ready() -> void:
	var damagable := GameActor.get_damagable(player)
	if damagable:
		health.value = ceil(float(damagable.current_health) / float(damagable.max_health) * health.max_value)
		damagable.on_health_changed.connect(
			func(new_health: int, max_health: int): 
				health.value = ceil(float(new_health) / float(max_health) * health.max_value)
		)
	player.on_boost_duration_changed.connect(
		func(new_duration: float, max_duration: float, player: Player):
			boost.value = ceil(float(new_duration) / float(max_duration) * boost.max_value)
			if player.is_boost_on_cd:
				boost.modulate = Color(Color.WHITE, .25)
			else: 
				boost.modulate = Color.WHITE, .5
				
	)
