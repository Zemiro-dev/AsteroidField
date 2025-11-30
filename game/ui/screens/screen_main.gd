extends CanvasLayer

@onready var launch_button: TextureButton = $PanelContainer/MarginContainer/VBoxContainer/LaunchButton
@onready var abort_button: TextureButton = $PanelContainer/MarginContainer/VBoxContainer/AbortButton


func _ready() -> void:
	launch_button.grab_focus.call_deferred()
	launch_button.pressed.connect(
		func(): 
			GameManager.new_game()
	)
	abort_button.pressed.connect(
		func():
			GameManager.quit_game()
	)
	Jukebox.play_menu_music()
