extends CanvasLayer

var paused: bool = false


func _ready() -> void:
	visible = false


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		if get_tree().paused == true and paused:
			paused = false
			get_tree().paused = false
			visible = false
		elif get_tree().paused != true and !paused:
			paused = true
			get_tree().paused = true
			visible = true
