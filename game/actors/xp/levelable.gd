extends Resource
class_name Levelable


signal on_xp_changed(xp: int, max_xp: int, level: int)
signal on_level_up(levelable: Levelable)


@export var max_xp: int = 10
@export var stat_modifiers: Array[LevelableStatModifier] = []

var xp: int = 0
var level: int = 1
var stats: LevelableStats


func _init() -> void:
	calc_stats()
	calc_max_xp()


func calc_stats() -> void:
	stats = LevelableStats.new()
	for modifier in stat_modifiers:
		modifier.modify(self, stats)


func calc_max_xp() -> void:
	max_xp = 5 * (level + 1)


func give_xp(add_xp: int) -> void:
	if add_xp <= 0: return
	
	xp = clampi(xp + add_xp, 0, max_xp)
	if xp == max_xp:
		level_up()
	on_xp_changed.emit(xp, max_xp, level)


func level_up() -> void:
	xp = 0
	level += 1
	calc_max_xp()
	on_level_up.emit(self)
