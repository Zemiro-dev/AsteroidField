extends Resource
class_name Levelable


signal on_xp_changed(xp: int, max_xp: int, level: int)


@export var max_xp: int = 10
var xp: int = 0
var level: int = 1
var stats: LevelableStats = LevelableStats.new()


func give_xp(add_xp: int) -> void:
	if add_xp <= 0: return
	
	xp = clampi(xp + add_xp, 0, max_xp)
	if xp == max_xp:
		level_up()
	on_xp_changed.emit(xp, max_xp, level)


func level_up() -> void:
	xp = 0
	level += 1
	if stats:
		level_up_projectile_stats()


func level_up_projectile_stats() -> void:
	@warning_ignore("integer_division")
	stats.projectile_damage_up = (level + 1) / 2
	stats.projectile_max_speed_up = 100.
	stats.projectile_acceleration_up = 100.
	stats.projectile_time_between_shots_mult = maxf(1. - (.05 * level), .001)
