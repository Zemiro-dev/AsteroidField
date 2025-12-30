extends CanvasLayer


@export var boot_world_scene := preload("res://world/boot/world_boot.tscn")


func _ready() -> void:
	if GameManager.install_data.data.get(GameManager.install_data.FIRST_LOAD):
		if boot_world_scene and boot_world_scene.can_instantiate():
			GameManager.change_scene(boot_world_scene)
			return
	GameManager.change_scene_to_main_menu()
