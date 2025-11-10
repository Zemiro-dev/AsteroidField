extends Node


enum Types { PLAYER, ENEMY, TERRAIN, UNKNOWN }


func get_actor_type(node: Node): 
	var current
	if node.has_method("get_actor_type"):
		var actor_type = node.get_actor_type();
		if (Types.has(actor_type)):
			return actor_type
	return Types.UNKNOWN
