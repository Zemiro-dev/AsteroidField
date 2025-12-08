extends Node

signal request_pause()
signal request_unpause()
signal paused()
signal unpaused()


var current_world: String = "res://world/debug/debug_world_a.tscn"
var game_start_world := preload("res://world/debug/debug_world_a.tscn")
var pause_count: int = 0


func _ready() -> void:
	request_pause.connect(
		func():
			pause_count += 1
			if pause_count > 0 and get_tree().paused == false:
				get_tree().paused = true
				paused.emit()
			
	)
	request_unpause.connect(
		func():
			pause_count = maxi(pause_count - 1, 0)
			if pause_count == 0 and get_tree().paused == true:
				get_tree().paused = false
				unpaused.emit()
			
	)


func new_game():
	change_scene(game_start_world)


func quit_game():
	get_tree().quit()


func change_scene_to_main_menu():
	get_tree().change_scene_to_file("res://ui/screens/screen_main.tscn")


func change_scene(new_scene: PackedScene):
	current_world = new_scene.resource_path
	get_tree().change_scene_to_packed(new_scene)
