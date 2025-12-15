extends CanvasLayer
class_name VictoryScreen

@onready var reset_button: TextureButton = $PanelContainer/MarginContainer/CenterContainer/VBoxContainer/ResetButton


func _ready() -> void:
	visible = false
	GlobalSignals.request_game_win.connect(render)
	reset_button.pressed.connect(
		func():
			GameManager.change_scene_to_main_menu()
	)


func render() -> void:
	get_tree().paused = true
	visible = true
	reset_button.grab_focus.call_deferred()
