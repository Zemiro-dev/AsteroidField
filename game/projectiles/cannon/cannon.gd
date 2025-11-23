extends Area2D
class_name Cannon


@export var stats: CannonStats
@export var projectile_scene: PackedScene
@export_flags_2d_physics var blocked_by: int
var time_since_last_shot: float = 0


func _physics_process(delta: float) -> void:
	if stats and time_since_last_shot > stats.time_between_shots:
		var target = get_target()
		if !target.is_zero_approx():
			fire(target)
			time_since_last_shot = 0.0
	if stats and time_since_last_shot < stats.time_between_shots:
		time_since_last_shot += delta


func fire(target: Vector2) -> void:
	if projectile_scene:
		var projectile: Node2D = projectile_scene.instantiate()
		if projectile is Bolt:
			projectile.chamber(global_transform, target, collision_mask + blocked_by)
		GlobalSignals.request_projectile_spawn.emit(projectile)


func _hitscan(target:Vector2) -> void:
	var space_state := get_world_2d().direct_space_state
	var query := PhysicsRayQueryParameters2D.create(global_position, target, collision_mask, [self])
	var result := space_state.intersect_ray(query)
	var obj = result.get('collider')
	if obj is Object:
		var damagable = GameActor.get_damagable(obj)
		if damagable:
			print('hitscan fire!')
			damagable.take_damage(2)


func get_target() -> Vector2:
	var possible_targets := get_overlapping_bodies().filter(has_los)
	var target = closest(possible_targets)
	return target.global_position if target else Vector2.ZERO


func has_los(node: Node2D) -> bool:
	var space_state := get_world_2d().direct_space_state
	var query := PhysicsRayQueryParameters2D.create(global_position, node.global_position, blocked_by, [self])
	var result := space_state.intersect_ray(query)
	return result.is_empty()


func closest(nodes: Array[Node2D]) -> Node2D:
	var closest_node: Node2D = null
	var closest_sq_distance: float = INF
	for node in nodes:
		var node_sq_distance := node.global_position.distance_squared_to(global_position)
		if node_sq_distance < closest_sq_distance:
			closest_node = node
			closest_sq_distance = node_sq_distance 
	return closest_node
