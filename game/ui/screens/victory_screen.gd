extends CanvasLayer
class_name VictoryScreen

@onready var margin_container: MarginContainer = $MarginContainer
@onready var reset_button: TextureButton = $MarginContainer/CenterContainer/VBoxContainer/ResetButton
@export var slide_time: float = .3
var slide_tween: Tween

func _ready() -> void:
	visible = false
	offset.y = get_offscreen_y_offset()
	GlobalSignals.request_game_win.connect(
		func():
			await get_tree().create_timer(1.).timeout
			render()
	)

func slide_in() -> Signal:
	visible = true
	if slide_tween:
		slide_tween.kill()
		offset.y = get_offscreen_y_offset()
	slide_tween = get_tween()
	slide_tween.tween_property(self, "offset:y", 0, slide_time)
	return slide_tween.finished


func slide_out() -> Signal:
	if slide_tween:
		slide_tween.kill()
	slide_tween = get_tween()
	slide_tween.tween_property(self, "offset:y", get_offscreen_y_offset(), slide_time)
	slide_tween.finished.connect(func(): visible = false)
	return slide_tween.finished

func get_tween() -> Tween:
	var t = create_tween()
	t.set_trans(Tween.TRANS_SINE)
	return t

func get_offscreen_y_offset() -> float:
	return -margin_container.size.y

func render() -> void:
	get_tree().paused = true
	slide_in().connect(
		func():
			reset_button.pressed.connect(
				func():
					GameManager.change_scene_to_main_menu()
			)
	)
	reset_button.grab_focus.call_deferred()
