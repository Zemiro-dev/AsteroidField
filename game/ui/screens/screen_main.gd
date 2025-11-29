extends CanvasLayer

@onready var launch_button: TextureButton = $PanelContainer/MarginContainer/VBoxContainer/LaunchButton

func _ready() -> void:
	launch_button.grab_focus.call_deferred()
