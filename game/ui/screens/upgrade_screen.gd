extends CanvasLayer
class_name UpgradeScreen

signal upgrade_selected(upgrade: LevelableStatModifier)


@onready var upgrade_button_container: HBoxContainer = $PanelContainer/MarginContainer/CenterContainer/VBoxContainer/UpgradeButtonContainer
@onready var description: RichTextLabel = $PanelContainer/MarginContainer/CenterContainer/VBoxContainer/CenterContainer/UpgradeDescriptionBg/MarginContainer/Description
const UPGRADE_BUTTON: PackedScene = preload("res://ui/screens/upgrade/upgrade_button.tscn")


func _ready() -> void:
	visible = false


func bind_to_player(player: Player):
	var levelable := GameActor.get_levelable(player)
	if levelable:
		levelable.on_level_up.connect(
			func(_levelable: Levelable):
				var options: Array[LevelableStatModifier]
				if _levelable.stat_modifiers.size() > 0:
					var all_options := _levelable.stat_modifiers.duplicate()
					all_options = all_options.filter(
						func(option: LevelableStatModifier):
							return option.max_strength > option.strength
					)
					all_options.shuffle()
					options.assign(all_options.slice(0, 3).map(
						func(modifier: LevelableStatModifier):
							var clone: LevelableStatModifier = modifier.duplicate()
							clone.strength += 1
							return clone
					),)
					
				else:
					options = [LevelableStatModifier.ProjectileAttackSpeedUpPerLevel.new()]
				 
				if !options.is_empty():
					get_tree().paused = true
					render_for_options(options)
		)
		upgrade_selected.connect(
			func(upgrade: LevelableStatModifier):
				if upgrade:
					var modIndex: int = levelable.stat_modifiers.find_custom(
						func(modifier: LevelableStatModifier):
							return upgrade.code == modifier.code
					)
					if modIndex >= 0:
						levelable.stat_modifiers[modIndex] = upgrade
					else:
						levelable.stat_modifiers.append(upgrade)
					levelable.calc_stats()
					
				get_tree().paused = false
		)


func render_for_options(options: Array[LevelableStatModifier]) -> void:
	if options == null: return
	for child in upgrade_button_container.get_children():
		child.queue_free()
	var buttons: Array[UpgradeButton] = []
	for option in options:
		var button := UPGRADE_BUTTON.instantiate()
		buttons.append(button)
		button.modifier = option
		upgrade_button_container.add_child(button)
	if buttons.size() > 0:
		for button in buttons:
			button.pressed.connect(
				func():
					upgrade_selected.emit(button.modifier)
					visible = false
			)
			button.focus_entered.connect(
				func():
					description.text = 'Description: %s' % button.modifier.description
			)
		buttons[0].grab_focus.call_deferred()
	visible = true
