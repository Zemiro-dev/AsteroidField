extends Node


var current_world: String = "res://world/debug/debug_world_a.tscn"
var game_start_world := preload("res://world/debug/debug_world_a.tscn")
var game_win_count := 0

class InstallData extends RefCounted:
	const FIRST_LOAD = 'first_load'
	var data := {}
	func _init() -> void:
		data.set(FIRST_LOAD, true)

const INSTALL_DATA_PATH := "user://install.data"
@onready var install_data: InstallData = InstallData.new()


func _ready() -> void:
	GlobalSignals.request_game_win.connect(func(): game_win_count += 1)
	var loaded_install_data := get_install_data_from_file()
	install_data.data.merge(loaded_install_data, true)


func get_install_data_from_file() -> Dictionary:
	if not FileAccess.file_exists(INSTALL_DATA_PATH): return {}
	
	var install_data_file = FileAccess.open(INSTALL_DATA_PATH, FileAccess.READ)
	var json_data = install_data_file.get_line()
	var json = JSON.new()
	var parse_result = json.parse(json_data)
	if not parse_result == OK:
		return {}
	
	var data = json.data
	
	if typeof(data) == TYPE_DICTIONARY:
		return data
	return {}


func save_install_data(_install_data: InstallData) -> void:
	var install_data_file = FileAccess.open(INSTALL_DATA_PATH, FileAccess.WRITE)
	var json_string = JSON.stringify(_install_data.data)
	install_data_file.store_line(json_string)

func new_game():
	change_scene.call_deferred(game_start_world)


func quit_game():
	get_tree().quit()


func change_scene_to_main_menu():
	get_tree().paused = false
	get_tree().change_scene_to_file.call_deferred("res://ui/screens/screen_main.tscn")


func change_scene(new_scene: PackedScene):
	current_world = new_scene.resource_path
	get_tree().change_scene_to_packed.call_deferred(new_scene)
