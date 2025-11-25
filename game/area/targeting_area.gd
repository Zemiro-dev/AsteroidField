extends Area2D
class_name TargetingArea

@export_flags_2d_physics var blocked_by: int


func has_los(node: Node2D) -> bool:
	return Physics.has_los(self, node, blocked_by, [self])


func get_target() -> Vector2:
	var possible_targets := get_overlapping_bodies().filter(has_los)
	var target = Physics.closest(global_position, possible_targets)
	return target.global_position if target else Vector2.ZERO
