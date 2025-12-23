extends Resource
class_name LevelableStatModifier


enum LevelableStatModifierType { BUILT_IN, WEAPON_STAT, SPECIAL_STAT }


@export var priority: int = 0
@export var strength: int = 1
@export var max_strength: int = 5
@export var name: String
@export var code: String
@export var type: LevelableStatModifierType
@export var texture_path: String
@export var description: String


func modify(_levelable: Levelable, stats: LevelableStats) -> LevelableStats:
	return stats;


func strength_weight() -> float:
	return float(strength ) / float(max_strength)


class ProjectileDamageUpPerLevel extends LevelableStatModifier:
	func _init() -> void:
		name = 'Damage up'
		code = 'damage_up_level'
		type = LevelableStatModifierType.BUILT_IN
		texture_path = "res://assets/ui/upgrades/upgrade_attack_speed.png"
		description = 'Increases damage per level'


	func modify(levelable: Levelable, stats: LevelableStats) -> LevelableStats:
		@warning_ignore("integer_division")
		stats.projectile_damage_up += (levelable.level) / 2
		return stats


class ProjectileAttackSpeedUpPerLevel extends LevelableStatModifier:
	func _init() -> void:
		name = 'Attack Speed'
		code = 'attack_speed_level'
		type = LevelableStatModifierType.BUILT_IN
		texture_path = "res://assets/ui/upgrades/upgrade_attack_speed.png"
		description = 'Increases attack speed per level'


	func modify(levelable: Levelable, stats: LevelableStats) -> LevelableStats:
		stats.projectile_time_between_shots_mult = maxf(
			stats.projectile_time_between_shots_mult - (float(levelable.level) * .01)
		, .001)
		return stats


class ProjectileAttackSpeedUp extends LevelableStatModifier:
	func _init() -> void:
		name = 'Attack Speed'
		code = 'attack_speed'
		type = LevelableStatModifierType.WEAPON_STAT
		texture_path = "res://assets/ui/upgrades/upgrade_attack_speed.png"
		description = 'Increases attack speed per strength'
		max_strength = 5


	func modify(levelable: Levelable, stats: LevelableStats) -> LevelableStats:
		stats.projectile_time_between_shots_mult = maxf(
			stats.projectile_time_between_shots_mult - (.8 * strength_weight())
		, .001)
		return stats


class ProjectileBonusProjectile extends LevelableStatModifier:
	func _init() -> void:
		name = 'Extra Projectiles'
		code = 'extra_projectiles'
		type = LevelableStatModifierType.WEAPON_STAT
		texture_path = "res://assets/ui/upgrades/upgrade_projectile_count_up.png"
		description = 'Extra projectiles'


	func modify(levelable: Levelable, stats: LevelableStats) -> LevelableStats:
		stats.projectile_bonus_projectiles += clampi(strength, 0, max_strength)
		stats.projectile_spread_modifier += clampf(strength, 0, max_strength) * .3
		return stats


class ThrusterModifier extends LevelableStatModifier:
	@export var thruster_power := 400.
	func _init() -> void:
		name = 'Thrusters'
		code = 'thruster'
		type = LevelableStatModifierType.SPECIAL_STAT
		texture_path = "res://assets/ui/upgrades/upgrade_speed_up.png"
		description = 'Increases the strength of your thrusters'
		max_strength = 3


	func modify(levelable: Levelable, stats: LevelableStats) -> LevelableStats:
		var boost = thruster_power * strength_weight()
		stats.max_speed_up += boost
		stats.max_acceleration_up += boost * 2.
		stats.boost_power_up += clampf(
			lerpf(.0, 1., strength_weight()), 
			0., 
			1.
		)
		stats.boost_duration_increase += 1. * strength_weight()
		stats.boost_recharge_ratio += 1. * strength_weight()
		return stats


class TimeManipulator extends LevelableStatModifier:
	func _init() -> void:
		name = 'Time Manipulator'
		code = 'time_manipulator'
		type = LevelableStatModifierType.SPECIAL_STAT
		texture_path = "res://assets/ui/upgrades/upgrade_time_manipulator.png"
		description = 'Your boost is weaker, but can now manipulate time.'
		max_strength = 1


	func modify(levelable: Levelable, stats: LevelableStats) -> LevelableStats:
		stats.boost_power_up -= 1.
		stats.slow_time_on_boost = true
		stats.slow_time_on_boost_intensity = .5
		return stats


class FocusingCrystals extends LevelableStatModifier:
	func _init() -> void:
		name = 'Focusing Crystals'
		code = 'focusing_crystals'
		type = LevelableStatModifierType.WEAPON_STAT
		texture_path = "res://assets/ui/upgrades/upgrade_focusing_crystal.png"
		description = 'Increased damage and reduced spread through focusing crystals'
		max_strength = 5


	func modify(levelable: Levelable, stats: LevelableStats) -> LevelableStats:
		stats.projectile_damage_up += strength * 2
		stats.projectile_radial_spread_modifier = clampf(stats.projectile_radial_spread_modifier - strength_weight(), .1, 1.)
		return stats
