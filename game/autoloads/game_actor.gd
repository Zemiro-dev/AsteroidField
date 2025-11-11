extends Node


enum Types { PLAYER, ENEMY, TERRAIN, UNKNOWN }


func get_actor_type(o: Object): 
	var current
	if o.has_method("get_actor_type"):
		var actor_type = o.get_actor_type();
		if (Types.has(actor_type)):
			return actor_type
	return Types.UNKNOWN
