extends Node


enum ActorType { PLAYER, ENEMY, TERRAIN, UNKNOWN }


func get_actor_type(o: Object) -> ActorType:
	if o.has_method("get_actor_type"):
		var actor_type = o.get_actor_type()
		if ActorType.has(actor_type):
			return actor_type
	return ActorType.UNKNOWN


func get_steerable(o: Object) -> BaseSteerable:
	if o.has_method("get_steerable"):
		var steerable = o.get_steerable()
		if steerable is BaseSteerable:
			return steerable
	return null
