extends Node2D


@onready var player: Player = $Player
@onready var death_timer: Timer = $DeathTimer
@onready var player_camera: PlayerCamera = $PlayerCamera
@onready var upgrade_screen: UpgradeScreen = $UpgradeScreen
@onready var ui: PlayerResourceUi = $UI


func _ready() -> void:
	var damagable := GameActor.get_damagable(player)
	if damagable:
		damagable.on_death.connect(
			func(_actor: Node2D):
				death_timer.start()
		)
	var levelable := GameActor.get_levelable(player)
	if levelable:
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
	death_timer.timeout.connect(func(): GameManager.change_scene_to_main_menu())
	player_camera.player = player
	ui.bind_to_player(player)
