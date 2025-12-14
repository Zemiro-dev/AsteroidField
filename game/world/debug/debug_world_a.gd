extends Node2D


@onready var player: Player = $Player
@onready var health: TextureProgressBar = $UI/Health
@onready var boost: TextureProgressBar = $UI/Boost
@onready var xp: TextureProgressBar = $UI/Xp
@onready var level: TextureProgressBar = $UI/Level
@onready var death_timer: Timer = $DeathTimer
@onready var player_camera: PlayerCamera = $PlayerCamera
@onready var upgrade_screen: UpgradeScreen = $UpgradeScreen


func _ready() -> void:
	var damagable := GameActor.get_damagable(player)
	if damagable:
		health.value = ceil(float(damagable.current_health) / float(damagable.max_health) * health.max_value)
		damagable.on_health_changed.connect(
			func(new_health: int, max_health: int): 
				health.value = ceil(float(new_health) / float(max_health) * health.max_value)
		)
		damagable.on_death.connect(
			func(_actor: Node2D):
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
		levelable.on_level_up.connect(
			func(_levelable: Levelable):
				var options: Array[LevelableStatModifier]
				if _levelable.stat_modifiers.size() > 0:
					var all_options := _levelable.stat_modifiers.duplicate()
					all_options = all_options.filter(
						func(option: LevelableStatModifier):
							return option.max_strength > option.strength
					)
					all_options.shuffle()
					options.assign(all_options.slice(0, 3).map(
						func(modifier: LevelableStatModifier):
							var clone: LevelableStatModifier = modifier.duplicate()
							clone.strength += 1
							return clone
					),)
					
				else:
					options = [LevelableStatModifier.ProjectileAttackSpeedUpPerLevel.new()]
				 
				if !options.is_empty():					
					get_tree().paused = true
					upgrade_screen.render_for_options(options)
		)
		upgrade_screen.upgrade_selected.connect(
			func(upgrade: LevelableStatModifier):
				if upgrade:
					var modIndex: int = levelable.stat_modifiers.find_custom(
						func(modifier: LevelableStatModifier):
							return upgrade.code == modifier.code
					)
					if modIndex >= 0:
						levelable.stat_modifiers[modIndex] = upgrade
					else:
						levelable.stat_modifiers.append(upgrade)
					levelable.calc_stats()				
					
				get_tree().paused = false
		)
	player.on_boost_duration_changed.connect(
		func(new_duration: float, max_duration: float, _player: Player):
			boost.value = ceil(float(new_duration) / float(max_duration) * boost.max_value)
			if _player.is_boost_on_cd:
				boost.modulate = Color(Color.WHITE, .25)
			else: 
				boost.modulate = Color.WHITE
				
	)
	death_timer.timeout.connect(func(): GameManager.change_scene_to_main_menu())
	player_camera.player = player
