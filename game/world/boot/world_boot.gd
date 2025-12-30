extends Node2D

@onready var player: Player = $Player
@onready var player_camera: PlayerCamera = $PlayerCamera


func _ready() -> void:
	player_camera.player = player
	player_camera.make_current()
	player.controller.controllable = false
	player.force_thruster_particle_on = true
	player.damagable.is_invincible = true
	player.steerable.velocity = Vector2.DOWN * 300 # so enemies target
	Jukebox.set_master_muted(true)


func transition_to_main_menu() -> void:
	Jukebox.set_master_muted(false)
	GameManager.install_data.data.set(GameManager.install_data.FIRST_LOAD, false)
	GameManager.save_install_data(GameManager.install_data)
	GameManager.change_scene_to_main_menu()
	
