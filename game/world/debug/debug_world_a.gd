extends Node2D


@onready var player: Player = $Player
@onready var health: TextureProgressBar = $UI/Health


func _ready() -> void:
	var damagable := GameActor.get_damagable(player)
	if damagable:
		health.value = ceil(float(damagable.current_health) / float(damagable.max_health) * health.max_value)
		damagable.on_health_changed.connect(
			func(new_health: int, max_health: int): 
				health.value = ceil(float(new_health) / float(max_health) * health.max_value)
		)
