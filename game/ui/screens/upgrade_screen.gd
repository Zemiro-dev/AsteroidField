extends CanvasLayer
class_name UpgradeScreen

signal upgrade_selected(upgrade: LevelableStatModifier)


@onready var upgrade_button_container: HBoxContainer = $PanelContainer/MarginContainer/CenterContainer/VBoxContainer/UpgradeButtonContainer
const UPGRADE_BUTTON: PackedScene = preload("res://ui/screens/upgrade/upgrade_button.tscn")


func _ready() -> void:
	visible = false


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
		buttons[0].grab_focus.call_deferred()
		buttons[0].pressed.connect(
			func():
				upgrade_selected.emit(buttons[0].modifier)
				visible = false
		)
	visible = true
