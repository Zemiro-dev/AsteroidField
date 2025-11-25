extends Node


func closest(position: Vector2, nodes: Array[Node2D]) -> Node2D:
	var closest_node: Node2D = null
	var closest_sq_distance: float = INF
	for node in nodes:
		var node_sq_distance := node.global_position.distance_squared_to(position)
		if node_sq_distance < closest_sq_distance:
			closest_node = node
			closest_sq_distance = node_sq_distance 
	return closest_node


func has_los(observer: Node2D, node: Node2D, blocked_by: int = 0x00000000, exclude: Array[RID] = []) -> bool:
	var space_state := observer.get_world_2d().direct_space_state
	var query := PhysicsRayQueryParameters2D.create(observer.global_position, node.global_position, blocked_by, exclude)
	var result := space_state.intersect_ray(query)
	return result.is_empty()
