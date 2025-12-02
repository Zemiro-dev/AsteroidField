extends Resource
class_name Levelable


signal on_xp_changed(xp: int, max_xp: int, level: int)


@export var max_xp: int = 10
var xp: int = 0
var level: int = 1


func give_xp(add_xp: int) -> void:
	if add_xp <= 0: return
	
	xp = clampi(xp + add_xp, 0, max_xp)
	if xp == max_xp:
		xp = 0
		level += 1
	on_xp_changed.emit(xp, max_xp, level)
