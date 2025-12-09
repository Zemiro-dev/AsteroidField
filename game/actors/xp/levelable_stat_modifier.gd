extends Resource
class_name LevelableStatModifier


enum LevelableStatModifierType { WEAPON_STAT }


@export var priority: int = 0
@export var strength: int = 1
@export var max_strength: int = 5
@export var name: String
@export var code: String
@export var type: LevelableStatModifierType
@export var texture_path: String


func modify(levelable: Levelable, stats: LevelableStats) -> LevelableStats:
	return stats;


func strength_weight() -> float:
	return float(strength ) / float(max_strength)


class ProjectileDamageUpPerLevel extends LevelableStatModifier:
	func _init() -> void:
		name = 'Damage up'
		code = 'damage_up'
		type = LevelableStatModifierType.WEAPON_STAT


	func modify(levelable: Levelable, stats: LevelableStats) -> LevelableStats:
		@warning_ignore("integer_division")
		stats.projectile_damage_up += (levelable.level + strength) / 2
		return stats


class ProjectileAttackSpeedUpPerLevel extends LevelableStatModifier:
	func _init() -> void:
		name = 'Attack Speed'
		code = 'attack_speed'
		type = LevelableStatModifierType.WEAPON_STAT
		texture_path = "res://assets/ui/upgrades/upgrade_attack_speed.png"


	func modify(levelable: Levelable, stats: LevelableStats) -> LevelableStats:
		var scale: float = lerp(.0, .05, strength_weight())
		stats.projectile_time_between_shots_mult = maxf(
			stats.projectile_time_between_shots_mult - (scale * levelable.level)
		, .001)
		return stats
