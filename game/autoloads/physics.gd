extends Node2D


func closest(_position: Vector2, nodes: Array[Node2D]) -> Node2D:
	var closest_node: Node2D = null
	var closest_sq_distance: float = INF
	for node in nodes:
		var node_sq_distance := node.global_position.distance_squared_to(_position)
		if node_sq_distance < closest_sq_distance:
			closest_node = node
			closest_sq_distance = node_sq_distance 
	return closest_node


func has_los(observer: Node2D, node: Node2D, blocked_by: int = 0x00000000, exclude: Array[RID] = []) -> bool:
	var space_state := observer.get_world_2d().direct_space_state
	var query := PhysicsRayQueryParameters2D.create(observer.global_position, node.global_position, blocked_by, exclude)
	var result := space_state.intersect_ray(query)
	return result.is_empty()


func is_circle_empty(center: Vector2, radius: float = 64, collision_mask: int = 0x00000000 ) -> bool:
	var space_state := get_world_2d().direct_space_state
	var query := PhysicsShapeQueryParameters2D.new()
	var circle_rid := PhysicsServer2D.circle_shape_create()
	PhysicsServer2D.shape_set_data(circle_rid, radius)
	query.shape_rid = circle_rid
	query.transform = Transform2D(0., center)
	query.collide_with_areas = false
	query.collide_with_bodies = true
	query.collision_mask = collision_mask
	var result = space_state.intersect_shape(query)
	return result.is_empty()
	
