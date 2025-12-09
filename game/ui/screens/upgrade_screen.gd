extends CanvasLayer
class_name UpgradeScreen


@onready var upgrade_button_container: HBoxContainer = $PanelContainer/MarginContainer/CenterContainer/VBoxContainer/UpgradeButtonContainer
const UPGRADE_BUTTON: PackedScene = preload("res://ui/screens/upgrade/upgrade_button.tscn")


func _ready() -> void:
	render_for_options([
		LevelableStatModifier.ProjectileAttackSpeedUpPerLevel.new()
	])


func render_for_options(options: Array[LevelableStatModifier]) -> void:
	for child in upgrade_button_container.get_children():
		child.queue_free()
	for option in options:
		var button := UPGRADE_BUTTON.instantiate()
		button.modifier = option
		upgrade_button_container.add_child(button)
