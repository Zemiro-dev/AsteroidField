extends TextureButton
class_name UpgradeButton


@onready var upgrade_texture: TextureRect = $MarginContainer/VBoxContainer/UpgradeTexture
@onready var upgrade_name: Label = $MarginContainer/VBoxContainer/MarginContainer/HBoxContainer/UpgradeName
@onready var upgrade_strength: Label = $MarginContainer/VBoxContainer/MarginContainer/HBoxContainer/UpgradeStrength

var modifier: LevelableStatModifier


const BUTTON_UPGRADE_WEAPONSTAT_FOCUSED = preload("res://assets/ui/screens/upgrade/button_upgrade_weaponstat_focused.png")
const BUTTON_UPGRADE_WEAPONSTAT_NORMAL = preload("res://assets/ui/screens/upgrade/button_upgrade_weaponstat_normal.png")


func _ready() -> void:
	if modifier:
		bind_to_stat_modifier(modifier)


func bind_to_stat_modifier(modifier: LevelableStatModifier):
	match(modifier.type):
		LevelableStatModifier.LevelableStatModifierType.WEAPON_STAT:
			set_to_weapon_stat_textures()
	upgrade_texture.texture = load(modifier.texture_path)
	upgrade_name.text = modifier.name
	upgrade_strength.text = '%d' % modifier.strength


func set_to_weapon_stat_textures() -> void:
	texture_normal = BUTTON_UPGRADE_WEAPONSTAT_NORMAL
	texture_focused = BUTTON_UPGRADE_WEAPONSTAT_FOCUSED
	texture_hover = BUTTON_UPGRADE_WEAPONSTAT_FOCUSED
