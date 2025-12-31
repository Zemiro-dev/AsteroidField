extends CanvasLayer
class_name PlayerResourceUi


@onready var health: TextureProgressBar = $ResourceBarContainer/VBoxContainer/Health
@onready var boost: TextureProgressBar = $ResourceBarContainer/VBoxContainer/Boost
@onready var xp: TextureProgressBar = $ResourceBarContainer/VBoxContainer/Xp
@onready var level: TextureProgressBar = $ResourceBarContainer/VBoxContainer/Level
@onready var stopwatch_label: StopwatchLabel = $BottomRightContainer/StopwatchLabel
@onready var target_health: ProgressBar = $TargetResourceContainer/TargetHealth
var target_types = [
	GameActor.ActorType.ENEMY
]
var last_struck_actor: Node2D
var target_health_tween: Tween
var target_health_show_time := .1
var target_health_hide_time := 10.0
@export var target_health_max_alpha := .8

func _ready() -> void:
	target_health.modulate.a = 0.0

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
	GlobalSignals.on_actor_damaged.connect(
		func(damaged_actor: Node2D, damagable: BaseDamagable):
			var actor_type := GameActor.get_actor_type(damaged_actor)
			var is_valid_actor := target_types.has(actor_type)
			if (!is_valid_actor): return
			if damagable.max_health < 100: return # only track big targets
			if damagable.current_health <= 0 && damaged_actor != last_struck_actor: return
			if target_health_tween: target_health_tween.kill()
			target_health_tween = create_tween()
			target_health_tween.tween_property(target_health, "modulate:a", target_health_max_alpha, target_health_show_time).from_current()
			target_health_tween.tween_property(target_health, "modulate:a", 0., target_health_hide_time)
			target_health.value = float(damagable.current_health) / float(damagable.max_health) * 100.0
			last_struck_actor = damaged_actor
				
	)
	stopwatch_label.is_stopped = false
