extends CanvasLayer
class_name PlayerResourceUi


@onready var health: TextureProgressBar = $Health
@onready var boost: TextureProgressBar = $Boost
@onready var xp: TextureProgressBar = $Xp
@onready var level: TextureProgressBar = $Level
@onready var stopwatch_label: StopwatchLabel = $MarginContainer/StopwatchLabel


func bind_to_player(player: Player):
	var damagable := GameActor.get_damagable(player)
	if damagable:
		health.value = ceil(float(damagable.current_health) / float(damagable.max_health) * health.max_value)
		damagable.on_health_changed.connect(
			func(new_health: int, max_health: int): 
				health.value = ceil(float(new_health) / float(max_health) * health.max_value)
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
		func(new_duration: float, max_duration: float, _player: Player):
			boost.value = ceil(float(new_duration) / float(max_duration) * boost.max_value)
			if _player.is_boost_on_cd:
				boost.modulate = Color(Color.WHITE, .25)
			else: 
				boost.modulate = Color.WHITE
	)
	stopwatch_label.is_stopped = false
