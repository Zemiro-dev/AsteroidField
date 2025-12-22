extends CanvasLayer
class_name UpgradeScreen

signal upgrade_selected(upgrade: LevelableStatModifier)

@onready var margin_container: MarginContainer = $MarginContainer
@onready var upgrade_button_container: HBoxContainer = $MarginContainer/CenterContainer/VBoxContainer/UpgradeButtonContainer
@onready var description: RichTextLabel = $MarginContainer/CenterContainer/VBoxContainer/CenterContainer/UpgradeDescriptionBg/MarginContainer/Description
const UPGRADE_BUTTON: PackedScene = preload("res://ui/screens/upgrade/upgrade_button.tscn")

@export var slide_time: float = .3
var slide_tween: Tween
var is_game_won := false


func _ready() -> void:
	visible = false
	offset.y = get_offscreen_y_offset()
	GlobalSignals.request_game_win.connect(
		func():
			visible = false
			is_game_won = true
			clear_buttons()
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


func bind_to_player(player: Player):
	var levelable := GameActor.get_levelable(player)
	if levelable:
		levelable.on_level_up.connect(
			func(_levelable: Levelable):
				var options := RewardManager.get_possislbe_level_up_rewards(_levelable)	 
				if !options.is_empty() and !is_game_won:
					get_tree().paused = true
					render_for_options(options)
		)
		upgrade_selected.connect(
			func(upgrade: LevelableStatModifier):
				RewardManager.apply_reward(levelable, upgrade)					
				get_tree().paused = false
		)


func clear_buttons():
	for child in upgrade_button_container.get_children():
		child.queue_free()
	
func render_for_options(options: Array[LevelableStatModifier]) -> void:
	if options == null: return
	clear_buttons()
	var buttons: Array[UpgradeButton] = []
	for option in options:
		var button := UPGRADE_BUTTON.instantiate()
		buttons.append(button)
		button.modifier = option
		upgrade_button_container.add_child(button)
	var slide_in_finished := slide_in()
	if buttons.size() > 0:
		for button in buttons:
			slide_in_finished.connect(
				func():
					if is_game_won:
						visible = false
					else:
						button.pressed.connect(
							func():
								slide_out().connect(func(): upgrade_selected.emit(button.modifier))
						)
			)
			button.focus_entered.connect(
				func():
					description.text = 'Description: %s' % button.modifier.description
			)
		buttons[0].grab_focus.call_deferred()
