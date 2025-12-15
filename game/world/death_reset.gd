extends Timer
class_name DeathReset


@export var reset_scene: PackedScene


func bind_to_player(player: Player) -> void:
	var damagable := GameActor.get_damagable(player)
	if damagable:
		damagable.on_death.connect(
			func(_actor: Node2D):
				start()
		)
	timeout.connect(
		func():
			if reset_scene:
				get_tree().change_scene_to_packed(reset_scene)
			else:
				GameManager.change_scene_to_main_menu()
			
	)
