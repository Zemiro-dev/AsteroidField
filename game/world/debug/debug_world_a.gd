extends Node2D


@onready var player: Player = $Player
@onready var health: TextureProgressBar = $UI/Health
@onready var boost: TextureProgressBar = $UI/Boost
@onready var xp: TextureProgressBar = $UI/Xp
@onready var level: TextureProgressBar = $UI/Level
@onready var death_timer: Timer = $DeathTimer
@onready var player_camera: PlayerCamera = $PlayerCamera


func _ready() -> void:
	var damagable := GameActor.get_damagable(player)
	if damagable:
		health.value = ceil(float(damagable.current_health) / float(damagable.max_health) * health.max_value)
		damagable.on_health_changed.connect(
			func(new_health: int, max_health: int): 
				health.value = ceil(float(new_health) / float(max_health) * health.max_value)
		)
		damagable.on_death.connect(
			func(actor: Node2D):
				death_timer.start()
		)
	var levelable := GameActor.get_levelable(player)
	if levelable:
		level.value = (levelable.level - 1)
		xp.value = ceil(float(levelable.xp) / float(levelable.max_xp) * xp.max_value)
		levelable.on_xp_changed.connect(
			func(current_xp: int, max_xp: int, current_level: int):
				xp.value = ceil(float(current_xp) / float(max_xp) * xp.max_value)
				level.value = current_level - 1
		)
	player.on_boost_duration_changed.connect(
		func(new_duration: float, max_duration: float, player: Player):
			boost.value = ceil(float(new_duration) / float(max_duration) * boost.max_value)
			if player.is_boost_on_cd:
				boost.modulate = Color(Color.WHITE, .25)
			else: 
				boost.modulate = Color.WHITE
				
	)
	death_timer.timeout.connect(func(): GameManager.change_scene_to_main_menu())
	player_camera.player = player
