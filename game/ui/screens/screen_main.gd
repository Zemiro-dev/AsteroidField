extends CanvasLayer

@onready var launch_button: TextureButton = $PanelContainer/MarginContainer/VBoxContainer/LaunchButton
@onready var abort_button: TextureButton = $PanelContainer/MarginContainer/VBoxContainer/AbortButton
@onready var credit: Label = $PanelContainer/MarginContainer/VBoxContainer/Credit


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
	if GameManager.game_win_count > 0:
		credit.text = 'a game for my Wife'
