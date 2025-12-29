extends Node2D


@onready var player: Player = $Player
@onready var player_camera: PlayerCamera = $PlayerCamera
@onready var ui: PlayerResourceUi = $UI
@onready var death_reset: DeathReset = $DeathReset
@onready var upgrade_screen: UpgradeScreen = $UpgradeScreen
@onready var goal_enemies: Node2D = $GoalEnemies
var death_count_goal := 0
var death_count = 0

func _ready() -> void:
	player_camera.player = player
	ui.bind_to_player(player)
	death_reset.bind_to_player(player)
	upgrade_screen.bind_to_player(player)
	for child in goal_enemies.get_children():
		var damagable := GameActor.get_damagable(child)
		if damagable:
			watch_damagable(child, damagable)

func watch_damagable(body: Node2D, damagable: BaseDamagable) -> void:
	player.add_goal(body)
	death_count_goal += 1
	damagable.on_death.connect(
		func(actor: Node2D):
			death_count += 1
			if death_count >= death_count_goal:
				GlobalSignals.request_game_win.emit()
	)
