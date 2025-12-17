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
		code = 'damage_up'
		type = LevelableStatModifierType.WEAPON_STAT
		texture_path = "res://assets/ui/upgrades/upgrade_attack_speed.png"
		description = 'Increases damage per level'
		max_strength = 10


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
		description = 'Increases attack speed per level'
		max_strength = 10


	func modify(levelable: Levelable, stats: LevelableStats) -> LevelableStats:
		var scale: float = lerp(.0, .05, strength_weight())
		stats.projectile_time_between_shots_mult = maxf(
			stats.projectile_time_between_shots_mult - (scale * levelable.level)
		, .001)
		return stats


class ProjectileBonusProjectile extends LevelableStatModifier:
	func _init() -> void:
		name = 'Extra Projectiles'
		code = 'extra_projectiles'
		type = LevelableStatModifierType.WEAPON_STAT
		texture_path = "res://assets/ui/upgrades/upgrade_attack_speed.png"
		description = 'Extra projectiles'


	func modify(levelable: Levelable, stats: LevelableStats) -> LevelableStats:
		stats.projectile_bonus_projectiles += clampi(strength - 1, 0, max_strength)
		return stats

class ThrusterModifier extends LevelableStatModifier:
	@export var thruster_power := 100.
	func _init() -> void:
		name = 'Thrusters'
		code = 'thruster'
		type = LevelableStatModifierType.SPECIAL_STAT
		texture_path = "res://assets/ui/upgrades/upgrade_attack_speed.png"
		description = 'Increases the strength of your thrusters'
		max_strength = 5


	func modify(levelable: Levelable, stats: LevelableStats) -> LevelableStats:
		var boost = thruster_power * float(levelable.level) * strength_weight()
		stats.max_speed_up += boost
		stats.max_acceleration_up += boost
		stats.boost_power_up = clampf(lerpf(.0, 1., strength_weight()), 0., 1.)
		return stats
