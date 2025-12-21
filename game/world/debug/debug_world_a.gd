extends Node2D


@onready var player: Player = $Player
@onready var player_camera: PlayerCamera = $PlayerCamera
@onready var ui: PlayerResourceUi = $UI
@onready var death_reset: DeathReset = $DeathReset
@onready var upgrade_screen: UpgradeScreen = $UpgradeScreen

@onready var target_dummy: TargetDummy = $Enemies/TargetDummy
@onready var target_dummy_2: TargetDummy = $Enemies/TargetDummy2
@onready var target_dummy_3: TargetDummy = $Enemies/TargetDummy3
@onready var target_dummy_4: TargetDummy = $Enemies/TargetDummy4
@onready var target_dummy_5: TargetDummy = $Enemies/TargetDummy5
var death_count = 0

func _ready() -> void:
	player_camera.player = player
	ui.bind_to_player(player)
	death_reset.bind_to_player(player)
	upgrade_screen.bind_to_player(player)
	watch_dummy(target_dummy)
	watch_dummy(target_dummy_2)
	watch_dummy(target_dummy_3)
	watch_dummy(target_dummy_4)
	watch_dummy(target_dummy_5)

func watch_dummy(target_dummy: TargetDummy) -> void:
	var d := GameActor.get_damagable(target_dummy)
	if d:
		player.add_goal(target_dummy)
		d.on_death.connect(
			func(actor: Node2D):
				death_count += 1
				if death_count == 1:
					GlobalSignals.request_game_win.emit()
		)
