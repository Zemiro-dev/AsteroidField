extends Node



var current_world: String = "res://world/debug/debug_world_a.tscn"
var game_start_world := preload("res://world/debug/debug_world_a.tscn")


func new_game():
	change_scene(game_start_world)


func quit_game():
	get_tree().quit()


func change_scene_to_main_menu():
	get_tree().change_scene_to_file("res://ui/screens/screen_main.tscn")


func change_scene(new_scene: PackedScene):
	current_world = new_scene.resource_path
	get_tree().change_scene_to_packed(new_scene)
