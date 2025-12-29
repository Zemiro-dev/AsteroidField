extends CanvasLayer

class InstallData extends RefCounted:
	const FIRST_LOAD = 'first_load'
	var data := {}
	func _init() -> void:
		data.set(FIRST_LOAD, true)

const INSTALL_DATA_PATH := "user://install.data"
var install_data: InstallData

func _ready() -> void:
	load_install_data()
	save_install_data()
	GameManager.change_scene_to_main_menu()


func load_install_data() -> void:
	install_data = InstallData.new()
	if not FileAccess.file_exists(INSTALL_DATA_PATH): return
	
	var install_data_file = FileAccess.open(INSTALL_DATA_PATH, FileAccess.READ)
	var json_data = install_data_file.get_line()
	var json = JSON.new()
	var parse_result = json.parse(json_data)
	if not parse_result == OK:
		return
	
	var data = json.data
	
	if typeof(data) == TYPE_DICTIONARY:
		install_data.data.assign(data)
		


func save_install_data() -> void:
	var install_data_file = FileAccess.open(INSTALL_DATA_PATH, FileAccess.WRITE)
	var json_string = JSON.stringify(install_data.data)
	install_data_file.store_line(json_string)
